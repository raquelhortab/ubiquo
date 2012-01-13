Ubiquo::Engine.routes.draw do
  match "login" => "sessions#new", :via => :get, :as => :login
  match "login" => "sessions#create", :via => :post, :as => :logout
  match "logout" => "sessions#destroy", :via => :delete, :as => :logout
  resource :session
  resource :superadmin_mode
  resource :superadmin_home
  resource :password
  resource :ubiquo_user_profile
  resources :ubiquo_users
end
