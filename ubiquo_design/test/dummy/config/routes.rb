Dummy::Application.routes.draw do
  mount Ubiquo::Engine       => '/ubiquo'
  mount UbiquoDesign::Engine => '/' # public routes
end
