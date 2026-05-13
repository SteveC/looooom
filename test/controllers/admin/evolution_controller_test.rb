require "test_helper"

module Admin
  class EvolutionControllerTest < ActionDispatch::IntegrationTest
    test "rejects missing runner token" do
      get admin_evolution_context_url(format: :json)

      assert_response :unauthorized
    end

    test "returns context with shared secret" do
      with_env "EVOLUTION_RUNNER_TOKEN", "secret-runner-token" do
        get admin_evolution_context_url(format: :json), headers: { "Authorization" => "Bearer secret-runner-token" }
      end

      assert_response :success
      body = JSON.parse(response.body)
      assert_equal "last 7 days", body.dig("usage_summary", "window")
      assert_kind_of Array, body.fetch("tickets")
    end

    test "creates evolution run with shared secret" do
      with_env "EVOLUTION_RUNNER_TOKEN", "secret-runner-token" do
        assert_difference("EvolutionRun.count") do
          post admin_evolution_runs_url(format: :json),
               params: { evolution_run: { ticket_id: tickets(:one).id, status: "opened_pr", branch_name: "evolution/one", pull_request_url: "https://github.com/SteveC/looooom/pull/10" } },
               headers: { "X-Evolution-Runner-Token" => "secret-runner-token" }
        end
      end

      assert_response :created
      assert_equal "opened_pr", EvolutionRun.last.status
    end

    test "successful evolution run ships linked ticket" do
      ticket = tickets(:one)
      ticket.update!(status: "open")

      with_env "EVOLUTION_RUNNER_TOKEN", "secret-runner-token" do
        post admin_evolution_runs_url(format: :json),
             params: { evolution_run: { ticket_id: ticket.id, status: "succeeded", branch_name: "main", summary: "Fixed the bug.", validation: "bin/rails test" } },
             headers: { "Authorization" => "Bearer secret-runner-token" }
      end

      assert_response :created
      assert_equal "shipped", ticket.reload.status
    end

    test "failed evolution run does not ship linked ticket" do
      ticket = tickets(:one)
      ticket.update!(status: "open")

      with_env "EVOLUTION_RUNNER_TOKEN", "secret-runner-token" do
        post admin_evolution_runs_url(format: :json),
             params: { evolution_run: { ticket_id: ticket.id, status: "failed", branch_name: "main", summary: "Could not fix safely." } },
             headers: { "Authorization" => "Bearer secret-runner-token" }
      end

      assert_response :created
      assert_equal "open", ticket.reload.status
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
