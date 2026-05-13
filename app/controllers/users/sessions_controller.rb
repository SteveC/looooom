module Users
  class SessionsController < Devise::SessionsController
    before_action :prevent_auth_page_caching, only: :new

    def create
      redirect_to new_user_session_path, alert: "Use Google to sign in to loom."
    end

    private

    def prevent_auth_page_caching
      response.cache_control.replace(no_store: true)
    end
  end
end
