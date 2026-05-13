module Openai
  class TicketEmbedding
    MODEL = "text-embedding-3-small"

    def initialize(ticket, client: Client.new)
      @ticket = ticket
      @client = client
    end

    def call
      return unless Client.configured?

      response = client.post_json(
        "/v1/embeddings",
        {
          model: MODEL,
          input: "#{ticket.title}\n\n#{ticket.description}"
        }
      )
      embedding = response.fetch("data").first.fetch("embedding")
      ticket.update!(embedding: embedding, embedding_model: MODEL)
      embedding
    end

    private

    attr_reader :ticket, :client
  end
end
