# -*- encoding: utf-8 -*-

Ubiquo::Engine.routes.draw do
  resources :static_pages do
    member do
      put :publish
      put :unpublish
    end
  end

  resources :pages do
    resources :design do
      member do
        get :preview
        put :publish
        put :unpublish
      end

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
  end
end

# Those routes should be mounted at '/'
UbiquoDesign::Engine.routes.draw do
  # Proposal for public routes.
  match '*url/page/:page' => 'pages#show', :constraints => { :page => /\d*/ }
  match '*url' => 'pages#show'
end
