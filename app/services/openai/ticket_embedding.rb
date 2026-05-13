module Openai
  class TicketEmbedding
    MODEL = "text-embedding-3-small"

    def initialize(ticket, client: Client.new)
      @ticket = ticket
      @client = client
    end

    def call
      return unless Client.configured?

      model = ENV.fetch("OPENAI_EMBEDDING_MODEL", MODEL)
      response = client.post_json(
        "/v1/embeddings",
        {
          model: model,
          input: "#{ticket.title}\n\n#{ticket.description}"
        }
      )
      embedding = response.fetch("data").first.fetch("embedding")
      ticket.update!(embedding: embedding, embedding_model: model)
      embedding
    end

    private

    attr_reader :ticket, :client
  end
end
