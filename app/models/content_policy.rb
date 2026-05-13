class ContentPolicy
  Result = Data.define(:allowed?, :message)

  BLOCKED_PATTERNS = [
    /\b(?:porn|porno|pornography|xxx|onlyfans|nude|nudity|sex|sexual|escort|hookup)\b/i,
    /\b(?:blowjob|handjob|anal|incest|rape|rapist|bestiality|zoophilia)\b/i,
    /\b(?:kill yourself|kys|self[-\s]?harm|suicide instructions)\b/i,
    /\b(?:nazi|swastika|white power)\b/i
  ].freeze

  def self.check(*values)
    text = values.compact.join(" ")

    if BLOCKED_PATTERNS.any? { |pattern| text.match?(pattern) }
      Result.new(false, "Please keep tickets safe for work and appropriate for a product feedback board.")
    else
      Result.new(true, nil)
    end
  end
end
