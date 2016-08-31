Rails.application.routes.draw do
  get 'login' => 'authentication#login'
  get 'auth/:provider/callback' => 'authentication#callback'
  get 'join/:invite_token' => 'authentication#join', :as => 'join'
  delete 'logout' => 'authentication#logout'

  resources :zones do
    get :zone_file, :on => :member
    match :import, :on => :member, :via => [:get, :post]
    resources :records
  end
  resources :users

  match 'publish' => 'zones#publish', :via => [:get, :post]

  root 'zones#index'
end
