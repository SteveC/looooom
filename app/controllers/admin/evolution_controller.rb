module Admin
  class EvolutionController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_runner!

    def context
      render json: {
        generated_at: Time.current.iso8601,
        vote_threshold: vote_threshold,
        tickets: tickets.map { |ticket| ticket_payload(ticket) },
        usage_summary: usage_summary,
        recent_evolution_runs: EvolutionRun.latest.limit(10).map { |run| evolution_run_payload(run) }
      }
    end

    def create
      run = EvolutionRun.create!(evolution_run_params)
      render json: evolution_run_payload(run), status: :created
    end

    private

    def authenticate_runner!
      token = ENV["EVOLUTION_RUNNER_TOKEN"].to_s
      provided = request.authorization.to_s.delete_prefix("Bearer ").presence || request.headers["X-Evolution-Runner-Token"].to_s

      return if token.present? &&
                provided.present? &&
                provided.bytesize == token.bytesize &&
                ActiveSupport::SecurityUtils.secure_compare(provided, token)

      head :unauthorized
    end

    def tickets
      Ticket.implementation_candidates.openish.includes(:user, :comments).limit(50)
    end

    def ticket_payload(ticket)
      {
        id: ticket.id,
        title: ticket.title,
        description: ticket.description,
        status: ticket.status,
        priority: ticket.priority,
        votes_count: ticket.votes_count,
        comments_count: ticket.comments_count,
        created_at: ticket.created_at.iso8601,
        author_admin: ticket.user.configured_admin?,
        recent_comments: ticket.comments.visible.chronological.last(10).map do |comment|
          {
            id: comment.id,
            body: comment.body,
            created_at: comment.created_at.iso8601
          }
        end
      }
    end

    def usage_summary
      {
        window: "last 7 days",
        active_users: FeatureUsage.recent.distinct.count(:user_id),
        top_events: FeatureUsage.recent.group(:event_name).order(Arel.sql("COUNT(*) DESC")).limit(10).count
      }
    end

    def evolution_run_params
      permitted = params.expect(evolution_run: [
        :ticket_id,
        :status,
        :branch_name,
        :pull_request_url,
        :summary,
        :validation,
        :started_at,
        :completed_at,
        { runner_metadata: {} }
      ])
      permitted[:ticket_id] = nil if permitted[:ticket_id].blank?
      permitted
    end

    def evolution_run_payload(run)
      {
        id: run.id,
        ticket_id: run.ticket_id,
        status: run.status,
        branch_name: run.branch_name,
        pull_request_url: run.pull_request_url,
        summary: run.summary,
        validation: run.validation,
        created_at: run.created_at.iso8601
      }
    end

    def vote_threshold
      ENV.fetch("TICKET_IMPLEMENTATION_VOTE_THRESHOLD", 2).to_i
    end
  end
end
