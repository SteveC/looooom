require "test_helper"

class TicketCommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @ticket = tickets(:two)
    sign_in @user
  end

  test "creates comment on accepted ticket" do
    assert_difference("TicketComment.count") do
      post ticket_comments_url(@ticket), params: { ticket_comment: { body: "This would help my workflow." } }
    end

    assert_redirected_to ticket_url(@ticket)
    assert_equal @user, TicketComment.last.user
    assert_equal 2, @ticket.reload.comments_count
  end

  test "rejects blank comment" do
    assert_no_difference("TicketComment.count") do
      post ticket_comments_url(@ticket), params: { ticket_comment: { body: "" } }
    end

    assert_response :unprocessable_entity
  end
end
