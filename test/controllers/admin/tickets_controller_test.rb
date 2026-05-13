require "test_helper"

module Admin
  class TicketsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:one)
      @ticket = tickets(:two)
      @ticket.update!(review_status: "pending", accepted_at: nil)
    end

    test "configured admin can view holding pen" do
      with_env "ADMIN_EMAIL", @admin.email do
        sign_in @admin

        get admin_tickets_url

        assert_response :success
        assert_select "h1", "Ticket holding pen"
        assert_select "a[href=?]", ticket_path(@ticket)
      end
    end

    test "configured admin can accept ticket" do
      with_env "ADMIN_EMAIL", @admin.email do
        sign_in @admin

        patch admin_ticket_url(@ticket), params: { review_status: "accepted", review_reason: "Looks real." }

        assert_redirected_to admin_tickets_url
        assert_equal "accepted", @ticket.reload.review_status
        assert_equal "Looks real.", @ticket.review_reason
      end
    end

    private

    def with_env(key, value)
      previous = ENV[key]
      ENV[key] = value
      yield
    ensure
      ENV[key] = previous
    end
  end
end
