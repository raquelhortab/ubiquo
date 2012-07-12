Ubiquo::Engine.routes.draw do
  resource :locales
  filter :ubiquo_locale

  if Rails.env.test?
    match 'example_route', :controller => 'example_application', :action => 'show'
  end
end

