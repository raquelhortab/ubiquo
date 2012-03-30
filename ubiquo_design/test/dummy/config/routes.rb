Dummy::Application.routes.draw do
  mount UbiquoDesign::Engine => '/' # public routes
  mount Ubiquo::Engine       => '/ubiquo'
end
