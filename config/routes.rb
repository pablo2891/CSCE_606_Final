Rails.application.routes.draw do
  # Creates: POST /users (users#create), GET /users/new (users#new), GET /users/:id (users#show),
  resources :users, only: [ :new, :create, :show, :edit, :update ] do
    member do
      get :add_experience
      post :create_experience

      get  "edit_experience/:index", to: "users#edit_experience", as: :edit_experience
      patch "update_experience/:index", to: "users#update_experience", as: :update_experience

      get :add_education
      post :create_education

      get  "edit_education/:index", to: "users#edit_education", as: :edit_education
      patch "update_education/:index", to: "users#update_education", as: :update_education
    end
  end
  # Creates: GET /session/new (sessions#new), POST /session (sessions#create), DELETE /session (sessions#destroy)
  resource :session, only: [ :new, :create, :destroy ]

  # Company Verification GET /company_verifications/new (company_verifications#new),
  # POST /company_verifications (company_verifications#create), GET /company_verifications/:id (company_verifications#show)
  resources :company_verifications, only: [ :new, :create, :index, :destroy ] do
    member do
      get :verify   # e.g. /company_verifications/12/verify?token=xxx
    end
  end

  resources :referral_posts do
    resources :referral_requests, only: [ :create ]
  end

  # Login/logout
  # get "/login", to: "sessions#new"
  # post "/login", to: "sessions#create"
  # delete "/logout", to: "sessions#destroy"
  # get "/logout", to: "sessions#destroy"
  # get "/signup", to: "users#new"

  # Current user profile
  # get "/profile", to: "users#show"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root to: redirect("/users/new")



  # Email Verification Routes
  get "/verify_tamu", to: "email_verifications#verify_tamu"
  get "/verify_company", to: "email_verifications#verify_company"

  # Test routes - only in test environment
  if Rails.env.test?
    get "/test/protected_action", to: "application_controller_test#protected_action"
    get "/test/login_gate", to: "application_controller_test#login_gate"
  end

  # Catches all undefined routes and route errors, don't put anything below this line
  match "*unmatched", to: "redirect#fallback", via: :all
end
