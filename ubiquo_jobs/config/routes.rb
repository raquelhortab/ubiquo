Ubiquo::Engine.routes.draw do
  resources :jobs do
    get :history, :on => :collection
    member do
      put :repeat
      get :output
    end
  end
end
