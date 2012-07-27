Ubiquo::Engine.routes.draw do
  get "" => "home#index", :as => :home
  get "attachment/*path" => "attachment#show", :format => false, :as => :attachment
  resources :ubiquo_settings
end
