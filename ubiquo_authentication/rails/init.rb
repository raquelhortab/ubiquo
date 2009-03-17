require 'ubiquo_authentication'

default_per_page = Ubiquo::Config.get(:elements_per_page)
Ubiquo::Plugin.register(:ubiquo_authentication, directory, config) do |config|
  config.add :remember_time, 2.weeks
  
  config.add :user_navigator_permission, lambda{
    permit?("ubiquo_user_management")
  } 
  config.add :user_access_control, lambda{
    access_control :DEFAULT => "ubiquo_user_management"
  }
  
  config.add :ubiquo_users_elements_per_page, default_per_page
  config.add :ubiquo_users_admin_filter_enabled, true

  config.add :ubiquo_users_default_order_field, 'ubiquo_users.id'
  config.add :ubiquo_users_default_sort_order, 'DESC'
end


