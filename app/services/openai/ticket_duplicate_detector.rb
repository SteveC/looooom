module Openai
  class TicketDuplicateDetector
    SIMILARITY_THRESHOLD = 0.91

    def initialize(ticket)
      @ticket = ticket
    end

    def call
      return unless ticket.embedding.is_a?(Array)

      Ticket.accepted.where.not(id: ticket.id).where.not(embedding: nil).find_each do |candidate|
        next unless candidate.embedding.is_a?(Array)

        score = cosine(ticket.embedding, candidate.embedding)
        return { ticket: candidate, score: score } if score >= SIMILARITY_THRESHOLD
      end

      nil
    end

    private

    attr_reader :ticket

    def cosine(left, right)
      return 0.0 unless left.length == right.length

      dot = 0.0
      left_norm = 0.0
      right_norm = 0.0

      left.zip(right).each do |l_value, r_value|
        l = l_value.to_f
        r = r_value.to_f
        dot += l * r
        left_norm += l * l
        right_norm += r * r
      end

      return 0.0 if left_norm.zero? || right_norm.zero?

      dot / Math.sqrt(left_norm * right_norm)
    end
  end
end
