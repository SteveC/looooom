require "test_helper"

class TicketsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @ticket = tickets(:one)
    sign_in @user
  end

  test "should get index" do
    get tickets_url
    assert_response :success
  end

  test "should get new" do
    get new_ticket_url
    assert_response :success
  end

  test "should create ticket" do
    assert_difference("Ticket.count") do
      assert_enqueued_with(job: ProcessTicketJob) do
        post tickets_url, params: { ticket: { description: "Please add a compact mode.", priority: "normal", title: "Compact mode" } }
      end
    end

    assert_redirected_to ticket_url(Ticket.last)
    assert_equal @user, Ticket.last.user
  end

  test "should show ticket" do
    get ticket_url(@ticket)
    assert_response :success
  end

  test "should get edit" do
    get edit_ticket_url(@ticket)
    assert_response :success
  end

  test "should update ticket" do
    patch ticket_url(@ticket), params: { ticket: { description: @ticket.description, priority: "high", title: @ticket.title } }
    assert_redirected_to ticket_url(@ticket)
    assert_equal "high", @ticket.reload.priority
  end

  test "should destroy ticket" do
    assert_difference("Ticket.count", -1) do
      delete ticket_url(@ticket)
    end

    assert_redirected_to tickets_url
  end

  test "users cannot access other users tickets" do
    get ticket_url(tickets(:two))

    assert_response :not_found
  end
end
