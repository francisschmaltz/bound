Rails.application.routes.draw do
  get 'login' => 'authentication#login'
  get 'auth/:provider/callback' => 'authentication#callback'
  get 'join/:invite_token' => 'authentication#join', :as => 'join'
  delete 'logout' => 'authentication#logout'

  resources :zones do
    resources :records
  end
  resources :users

  root 'zones#index'
end
