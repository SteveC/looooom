module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      sign_in_from_omniauth
    end

    def github
      sign_in_from_omniauth
    end

    private

    def sign_in_from_omniauth
      @user = User.from_omniauth(request.env["omniauth.auth"])

      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider_name) if is_navigational_format?
    end

    def provider_name
      request.env["omniauth.auth"].provider.to_s.titleize
    end
  end
end
