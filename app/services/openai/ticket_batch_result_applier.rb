module Openai
  class TicketBatchResultApplier
    def initialize(batch_job, content)
      @batch_job = batch_job
      @content = content
    end

    def call
      content.each_line do |line|
        next if line.blank?

        apply_record(JSON.parse(line))
      end
    end

    private

    attr_reader :batch_job, :content

    def apply_record(record)
      ticket = Ticket.find_by(id: record.fetch("custom_id").delete_prefix("ticket-"))
      return unless ticket

      payload = extract_payload(record)
      apply_payload(ticket, payload)
    rescue JSON::ParserError, KeyError => error
      Rails.logger.warn("ticket_batch_result_failed batch_job_id=#{batch_job.id} error=#{error.class}: #{error.message}")
    end

    def extract_payload(record)
      body = record.dig("response", "body") || {}
      text = body.dig("output", 0, "content", 0, "text") ||
             body.dig("output", 0, "content", 0, "output_text") ||
             body["output_text"] ||
             body.dig("choices", 0, "message", "content")

      JSON.parse(text)
    end

    def apply_payload(ticket, payload)
      decision = payload.fetch("decision")
      reason = payload.fetch("reason")
      metadata = {
        openai_batch_job_id: batch_job.id,
        openai_batch_id: batch_job.openai_batch_id,
        ticket_triage_model: ENV.fetch("OPENAI_TICKET_TRIAGE_MODEL", "gpt-5-mini"),
        ticket_triage_decision: payload
      }

      if decision == "accepted"
        ticket.accept!(reason: reason, metadata: metadata)
      elsif decision == "duplicate"
        duplicate = Ticket.accepted.find_by(id: payload["duplicate_ticket_id"])
        ticket.hold!(review_status: duplicate ? "duplicate" : "held", reason: reason, duplicate_ticket: duplicate, metadata: metadata)
      elsif decision.in?(%w[held spam rejected])
        ticket.hold!(review_status: decision, reason: reason, metadata: metadata)
      else
        ticket.hold!(review_status: "held", reason: "Unknown model decision: #{decision}", metadata: metadata)
      end
    end
  end
end
