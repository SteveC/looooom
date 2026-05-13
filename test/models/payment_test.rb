require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  test "valid fixture" do
    assert_predicate payments(:one), :valid?
  end
end
