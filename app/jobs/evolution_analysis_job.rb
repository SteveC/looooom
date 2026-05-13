class EvolutionAnalysisJob < ApplicationJob
  queue_as :evolution

  def perform(trigger:, ticket_id: nil, requested_by_id: nil)
    log = EvolutionLog.create!(
      trigger: trigger,
      status: "running",
      started_at: Time.current,
      metrics_before: metrics_snapshot,
    )

    prompt = Evolution::PromptBuilder.new(
      trigger: trigger,
      ticket_id: ticket_id,
      requested_by_id: requested_by_id,
    ).build

    log.update!(
      status: "completed",
      summary: "Generated evolution prompt. CLI execution is disabled until the runner is isolated.",
      prompt: prompt,
      finished_at: Time.current,
      metrics_after: metrics_snapshot,
    )
  rescue StandardError => error
    log&.update!(
      status: "failed",
      summary: "#{error.class}: #{error.message}",
      finished_at: Time.current,
      metrics_after: metrics_snapshot,
    )

    raise
  end

  private

  def metrics_snapshot
    {
      tickets: Ticket.count,
      open_tickets: Ticket.openish.count,
      feature_usage_events_7d: FeatureUsage.recent.count,
      evolution_logs: EvolutionLog.count
    }
  end
end
