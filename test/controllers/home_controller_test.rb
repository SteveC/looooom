require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "root shows public discovery links and accepted content" do
    pending_ticket = users(:one).tickets.create!(
      title: "Private pending idea",
      description: "This should stay hidden from the public home page.",
      review_status: "pending"
    )

    get root_url

    assert_response :success
    assert_select "a[href=?]", tickets_path
    assert_select "a[href=?]", recent_tickets_path
    assert_select "a[href=?]", ticket_path(tickets(:one))
    assert_select "a[href=?]", ticket_path(pending_ticket), false
    assert_select "a[href=?]", user_path(users(:one))
    assert_select "body", text: /one@example.com/, count: 0
  end
end
