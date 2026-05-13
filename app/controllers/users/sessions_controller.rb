module Users
  class SessionsController < Devise::SessionsController
    def create
      redirect_to new_user_session_path, alert: "Use Google to sign in to loom."
    end
  end
end
