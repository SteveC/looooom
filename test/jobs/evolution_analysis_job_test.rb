require "test_helper"

class EvolutionAnalysisJobTest < ActiveJob::TestCase
  test "creates a completed evolution log with a prompt" do
    assert_difference("EvolutionLog.count") do
      EvolutionAnalysisJob.perform_now(trigger: "manual", requested_by_id: users(:admin).id)
    end

    log = EvolutionLog.latest.first
    assert_equal "completed", log.status
    assert_includes log.prompt, "loom Evolution Run"
    assert_includes log.prompt, "Ticket Signals"
  end
end
