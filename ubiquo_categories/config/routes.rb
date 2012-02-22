Ubiquo::Engine.routes.draw do 
  resources :category_sets do 
    resources :categories
  end
end
