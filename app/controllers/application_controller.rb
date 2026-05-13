class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def require_admin!
    authenticate_user!
    redirect_to dashboard_path, alert: "Admin access required." unless current_user.admin?
  end

  def require_configured_admin!
    authenticate_user!
    redirect_to dashboard_path, alert: "Admin access required." unless current_user.configured_admin?
  end

  def track_usage(event_name, metadata = {})
    return unless current_user

    current_user.feature_usages.create!(
      event_name: event_name,
      metadata: metadata,
      occurred_at: Time.current,
    )
  rescue ActiveRecord::ActiveRecordError => error
    Rails.logger.warn("feature_usage_failed event=#{event_name} error=#{error.class}: #{error.message}")
  end
end
