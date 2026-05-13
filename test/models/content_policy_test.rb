require "test_helper"

class ContentPolicyTest < ActiveSupport::TestCase
  test "allows ordinary product feedback" do
    result = ContentPolicy.check("Add dark mode", "Make late night usage easier.")

    assert result.allowed?
  end

  test "blocks unsafe product feedback" do
    result = ContentPolicy.check("Adult content", "Add porn content.")

    assert_not result.allowed?
    assert_equal "Please keep tickets safe for work and appropriate for a product feedback board.", result.message
  end
end
