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
      post tickets_url, params: { ticket: { description: "Please add a compact mode.", priority: "normal", title: "Compact mode" } }
    end

    assert_redirected_to ticket_url(Ticket.last)
    assert_equal @user, Ticket.last.user
  end

  test "should reject unsafe ticket content" do
    assert_no_difference("Ticket.count") do
      post tickets_url, params: { ticket: { description: "This contains unsafe adult content.", priority: "normal", title: "Porn request" } }
    end

    assert_response :unprocessable_entity
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

  test "users can view other users tickets" do
    get ticket_url(tickets(:two))

    assert_response :success
  end

  test "users cannot edit other users tickets" do
    get edit_ticket_url(tickets(:two))

    assert_response :not_found
  end

  test "should vote for ticket" do
    assert_difference("Vote.count") do
      post vote_ticket_url(tickets(:two))
    end

    assert_redirected_to ticket_url(tickets(:two))
    assert_equal 1, tickets(:two).reload.votes_count
  end

  test "should remove vote from ticket" do
    sign_in users(:two)

    assert_difference("Vote.count", -1) do
      delete vote_ticket_url(tickets(:one))
    end

    assert_redirected_to ticket_url(tickets(:one))
    assert_equal 0, tickets(:one).reload.votes_count
  end
end
