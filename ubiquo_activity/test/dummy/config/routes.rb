# -*- encoding: utf-8 -*-

Dummy::Application.routes.draw do
  mount Ubiquo::Engine => "/ubiquo"

  Ubiquo::Engine.routes.draw do
    resources :posts
  end
end
