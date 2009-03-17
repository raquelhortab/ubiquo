require 'ubiquo_access_control'

default_per_page = Ubiquo::Config.get(:elements_per_page)
Ubiquo::Plugin.register(:ubiquo_access_control, directory, config) do |config|
  
  config.add :role_access_control, lambda{
    access_control :DEFAULT => "role_management"
  }
  config.add :role_permit, lambda{
    permit?("role_management")
  }
  
  config.add :roles_elements_per_page, default_per_page
  config.add :roles_default_order_field, 'id'
  config.add :roles_default_sort_order, 'desc'
  
end
