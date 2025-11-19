Rails.application.routes.draw do
  resources :company_verifications, only: [ :new, :create, :show, :edit ]
  # Signup
  resources :users, only: [ :new, :create, :show ]
  resource :session, only: [ :new, :create, :destroy ]

  # Login/logout
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  get "/logout", to: "sessions#destroy"
  get "/signup", to: "users#new"

  # Current user profile
  get "/profile", to: "users#show"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "users#new"

  # Test routes - only in test environment
  if Rails.env.test?
    get "/test/protected_action", to: "application_controller_test#protected_action"
    get "/test/login_gate", to: "application_controller_test#login_gate"
  end

  # Catches all undefined routes and route errors, don't put anything below this line
  match "*unmatched", to: "redirect#fallback", via: :all
end
