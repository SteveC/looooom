module Admin
  class DashboardController < ApplicationController
    before_action :require_configured_admin!

    def show
      @stats = {
        total_users: User.count,
        configured_admins: User.configured_admin.count,
        total_tickets: Ticket.count,
        open_tickets: Ticket.openish.count,
        total_votes: Vote.count,
        usage_events_7d: FeatureUsage.recent.count,
        paid_subscriptions: Subscription.where(status: %w[active trialing]).count,
        paid_revenue_cents: Payment.where(status: "paid").sum(:amount_total)
      }

      @ticket_status_counts = Ticket.group(:status).count
      @ticket_priority_counts = Ticket.group(:priority).count
      @subscription_status_counts = Subscription.group(:status).count
      @popular_usage_events = FeatureUsage.recent.group(:event_name).order(Arel.sql("COUNT(*) DESC")).limit(10).count

      @top_tickets = Ticket.top.includes(:user).limit(10)
      @recent_tickets = Ticket.latest.includes(:user).limit(10)
      @recent_users = User.includes(:subscription).order(created_at: :desc).limit(10)
      @recent_payments = Payment.includes(:user).order(created_at: :desc).limit(8)
    end
  end
end
