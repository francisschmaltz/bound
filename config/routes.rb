Rails.application.routes.draw do
  get 'login' => 'authentication#login'
  get 'auth/:provider/callback' => 'authentication#callback'
  get 'join/:invite_token' => 'authentication#join', :as => 'join'
  match 'logout' => 'authentication#logout', :via => [:get, :delete]

  resources :zones do
    get :zone_file, :on => :member
    match :import, :on => :member, :via => [:get, :post]
    resources :records
  end
  resources :users
  resources :api_tokens

  match 'publish' => 'zones#publish', :via => [:get, :post]

  root 'zones#index'
end
