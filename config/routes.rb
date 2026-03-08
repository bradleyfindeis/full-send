Rails.application.routes.draw do
  resource :session
  resource :registration, only: %i[new create]
  resources :passwords, param: :token

  root "dashboard#index"

  resources :races, only: %i[index show] do
    resources :predictions, only: %i[new create edit update]
  end

  resource :season_prediction, only: %i[new create show]
  resource :settings, only: %i[edit update]
  resource :onboarding, only: %i[show update]
  resources :leaderboard, only: :index
  resources :results, only: %i[index show]

  namespace :admin do
    root "dashboard#index"
    resources :invite_codes, only: %i[index create destroy]
    resources :sync, only: :create
    resources :users, only: %i[index edit update destroy]
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "favicon" => "favicon#show"
end
