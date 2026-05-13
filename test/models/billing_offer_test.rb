require "test_helper"

class BillingOfferTest < ActiveSupport::TestCase
  test "normalizes currency" do
    offer = billing_offers(:one_time)
    offer.currency = "USD"

    assert_predicate offer, :valid?
    assert_equal "usd", offer.currency
  end

  test "requires recurring interval for subscriptions" do
    offer = billing_offers(:subscription)
    offer.recurring_interval = nil

    assert_not_predicate offer, :valid?
  end
end
