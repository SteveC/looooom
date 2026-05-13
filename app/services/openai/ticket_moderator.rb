module Openai
  class TicketModerator
    MODEL = "omni-moderation-latest"

    def initialize(ticket, client: Client.new)
      @ticket = ticket
      @client = client
    end

    def call
      return { flagged: false, skipped: true } unless Client.configured?

      response = client.post_json(
        "/v1/moderations",
        {
          model: MODEL,
          input: "#{ticket.title}\n\n#{ticket.description}"
        }
      )
      result = response.fetch("results").first
      { flagged: result.fetch("flagged"), categories: result["categories"], category_scores: result["category_scores"] }
    end

    private

    attr_reader :ticket, :client
  end
end
