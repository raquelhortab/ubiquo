# -*- encoding: utf-8 -*-

Ubiquo::Engine.routes.draw do
  resources :static_pages do
    member do
      put :publish
      put :unpublish
    end
  end

  resources :pages do
    resources :widgets do
      collection do
        # TODO: review this action
        get :change_order
        post :change_order
        put :change_order
        delete :change_order
      end

      member do
        post :change_name
      end
    end

    resources :blocks
  end

  match 'page/:page_id/design',
        :to => 'ubiquo/design#show',
        :as => :page_design
  match 'page/:page_id/design/preview',
        :to => 'ubiquo/design#preview',
        :as => :preview_page_design
  match 'page/:page_id/design/publish',
        :to => 'ubiquo/design#publish',
        :as => :publish_page_design
  match 'page/:page_id/design/unpublish',
        :to => 'ubiquo/design#unpublish',
        :as => :unpublish_page_design
end

Rails.application.routes.draw do
  # Proposal for public routes.
  match '/', :to => 'pages#show', :url => ''
  match '/page/:page',
        :to          => 'pages#show',
        :url         => '',
        :constraints => { :page => /\d*/ }
  match '/*url/page/:page', :to => 'pages#show', :constraints => { :page => /\d*/ }
  match '/*url/page/:page', :to => 'pages#show', :constraints => { :page => /\d*/ }
  match '/*url', :to => 'pages#show'
end
