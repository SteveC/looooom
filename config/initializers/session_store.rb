Rails.application.config.session_store(
  :cookie_store,
  key: "_looooom_session",
  same_site: :lax,
  secure: Rails.env.production?
)
