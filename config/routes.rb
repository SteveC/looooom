require "sidekiq/web"

Rails.application.routes.draw do
  root "home#index"

  get "dashboard", to: "dashboard#show"

  namespace :admin do
    root to: "dashboard#show"
    get "dashboard", to: "dashboard#show"
    resources :tickets, only: %i[index update]
    get "evolution/context", to: "evolution#context", defaults: { format: :json }
    post "evolution/runs", to: "evolution#create", defaults: { format: :json }
    resource :storage_test, only: :create
    resource :stripe_test, only: :create
    resource :cloudflare_email_test, only: :create
  end

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  get "u/:slug", to: "users#show", as: :user

  resources :tickets do
    collection do
      get :closed
    end

    member do
      post :vote
      delete :vote, action: :unvote
      post :reopen
    end

    resources :comments, controller: "ticket_comments", only: :create
  end
  namespace :billing do
    resource :checkout, only: :create
  end
  post "stripe/webhook", to: "stripe_webhooks#create"
  devise_for :users,
             skip: %i[ registrations passwords ],
             controllers: {
               omniauth_callbacks: "users/omniauth_callbacks",
               sessions: "users/sessions"
             }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
