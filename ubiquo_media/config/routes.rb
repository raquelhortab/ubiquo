# -*- encoding: utf-8 -*-

Ubiquo::Engine.routes.draw do
  resources :assets do
    collection do
      get :search
    end

    member do
      get :advanced_edit
      put :advanced_update
      post :restore
    end
  end
end
