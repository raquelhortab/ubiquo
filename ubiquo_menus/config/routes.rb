# -*- encoding: utf-8 -*-

Ubiquo::Engine.routes.draw do
  resources :menus do
    collection do
      get :nested_fields
    end
    member do
      get :nested_fields
    end
    resources :menu_items do
      member do
        put :update_positions
        put :toggle_active
      end
    end
  end
end
