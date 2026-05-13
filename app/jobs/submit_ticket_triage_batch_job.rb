class SubmitTicketTriageBatchJob < ApplicationJob
  queue_as :default
  BATCH_SIZE = 50

  def perform
    return unless Openai::Client.configured?
    return if OpenaiBatchJob.active.where(purpose: "ticket_triage").exists?

    tickets = Ticket.where(review_status: "pending")
                    .where("ai_review_metadata ->> 'openai_batch_job_id' IS NULL")
                    .latest
                    .limit(BATCH_SIZE)
    return if tickets.blank?

    batch_job = OpenaiBatchJob.create!(purpose: "ticket_triage", status: "queued", metadata: { ticket_ids: tickets.map(&:id) })
    jsonl = Openai::TicketBatchBuilder.new(tickets).jsonl
    client = Openai::Client.new
    file = client.upload_file(filename: "loom-ticket-triage-#{batch_job.id}.jsonl", content: jsonl, purpose: "batch")
    batch = client.post_json(
      "/v1/batches",
      {
        input_file_id: file.fetch("id"),
        endpoint: "/v1/responses",
        completion_window: "24h",
        metadata: { purpose: "ticket_triage", openai_batch_job_id: batch_job.id.to_s }
      }
    )

    batch_job.update!(
      status: batch.fetch("status"),
      openai_batch_id: batch.fetch("id"),
      input_file_id: file.fetch("id"),
      requested_at: Time.current
    )
    tickets.update_all(
      [
        "ai_review_metadata = ai_review_metadata || ?::jsonb",
        { openai_batch_job_id: batch_job.id, openai_batch_id: batch.fetch("id") }.to_json
      ]
    )

    PollOpenaiBatchJob.set(wait: 5.minutes).perform_later(batch_job.id)
  rescue StandardError => error
    batch_job&.update!(status: "failed", metadata: batch_job.metadata.merge(error: error.message))
    raise
  end
end
