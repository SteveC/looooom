module Evolution
  class PromptBuilder
    def initialize(trigger:, ticket_id: nil, requested_by_id: nil)
      @trigger = trigger
      @ticket_id = ticket_id
      @requested_by_id = requested_by_id
    end

    def build
      <<~PROMPT
        # EvoSite Evolution Run

        You are EvoSite's autonomous engineering agent. Inspect the repository, read the PRD and project context, choose one bounded improvement, implement it with tests, and create a pull request.

        ## Trigger

        #{trigger_context}

        ## Ticket Signals

        #{ticket_signals}

        ## Usage Signals

        #{usage_signals}

        ## Recent Evolution Logs

        #{evolution_history}

        ## Durable Project Context

        #{project_context}

        ## Required Guardrails

        - Do not expose secrets.
        - Do not run destructive git commands.
        - Keep the change small enough to review.
        - Run relevant tests before committing.
        - Open a GitHub pull request unless the environment blocks it.
      PROMPT
    end

    private

    attr_reader :trigger, :ticket_id, :requested_by_id

    def trigger_context
      lines = [ "- Trigger: #{trigger}" ]
      lines << "- Ticket ID: #{ticket_id}" if ticket_id
      lines << "- Requested by user ID: #{requested_by_id}" if requested_by_id
      lines.join("\n")
    end

    def ticket_signals
      tickets = selected_tickets
      return "No open tickets." if tickets.empty?

      tickets.map do |ticket|
        "- ##{ticket.id} [#{ticket.priority}/#{ticket.status}] #{ticket.title}\n  #{ticket.description.to_s.lines.first.to_s.strip}"
      end.join("\n")
    end

    def selected_tickets
      return Ticket.where(id: ticket_id).includes(:user) if ticket_id

      Ticket.openish.latest.limit(10).includes(:user)
    end

    def usage_signals
      events = FeatureUsage.recent.group(:event_name).count
      return "No usage events in the last 7 days." if events.empty?

      events.sort_by { |_event, count| -count }.map { |event, count| "- #{event}: #{count}" }.join("\n")
    end

    def evolution_history
      logs = EvolutionLog.latest.limit(5)
      return "No prior evolution logs." if logs.empty?

      logs.map { |log| "- #{log.created_at.iso8601} [#{log.status}] #{log.summary.presence || log.trigger}" }.join("\n")
    end

    def project_context
      [
        read_file("docs/evosite-prd.md"),
        read_file("docs/codex-evolution-prompt.md"),
        read_file("AGENTS.md"),
        read_file("CLAUDE.md")
      ].compact.join("\n\n---\n\n")
    end

    def read_file(relative_path)
      path = Rails.root.join(relative_path)
      return unless path.exist?

      path.read
    end
  end
end
