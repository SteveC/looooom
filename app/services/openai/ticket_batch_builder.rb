module Openai
  class TicketBatchBuilder
    MODEL = "gpt-5-mini"

    SCHEMA = {
      type: "object",
      additionalProperties: false,
      properties: {
        decision: { type: "string", enum: %w[accepted held spam duplicate rejected] },
        reason: { type: "string" },
        duplicate_ticket_id: { type: %w[integer null] }
      },
      required: %w[decision reason duplicate_ticket_id]
    }.freeze

    def initialize(tickets)
      @tickets = tickets
    end

    def jsonl
      tickets.map { |ticket| JSON.generate(line_for(ticket)) }.join("\n")
    end

    private

    attr_reader :tickets

    def line_for(ticket)
      {
        custom_id: "ticket-#{ticket.id}",
        method: "POST",
        url: "/v1/responses",
        body: {
          model: MODEL,
          input: [
            { role: "system", content: system_prompt },
            { role: "user", content: user_prompt(ticket) }
          ],
          text: {
            format: {
              type: "json_schema",
              name: "ticket_review",
              strict: true,
              schema: SCHEMA
            }
          }
        }
      }
    end

    def system_prompt
      <<~PROMPT.squish
        You classify product feedback tickets for loom. Accept real product feedback.
        Hold unclear, low-context, or risky requests for admin review. Mark spam for ads,
        abuse, nonsense, or irrelevant content. Mark duplicate only when one provided
        candidate clearly covers the same request. Do not invent duplicate IDs.
      PROMPT
    end

    def user_prompt(ticket)
      <<~PROMPT
        Ticket ##{ticket.id}
        Title: #{ticket.title}
        Description:
        #{ticket.description}

        Existing accepted tickets that may be duplicates:
        #{duplicate_candidates(ticket)}
      PROMPT
    end

    def duplicate_candidates(ticket)
      Ticket.accepted.where.not(id: ticket.id).top.limit(20).map do |candidate|
        "##{candidate.id}: #{candidate.title} - #{candidate.description.to_s.truncate(180)}"
      end.join("\n").presence || "None"
    end
  end
end
