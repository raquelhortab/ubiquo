Ubiquo::Plugin.register(:ubiquo_menus, :plugin => UbiquoMenus) do |config|
  config.add :menus_access_control, lambda{
    access_control :DEFAULT => "menus_management"
  }
  config.add :menus_permit, lambda{
    permit?("menus_management")
  }

  # Set to false to avoid displaying editing options in Ubiquo
  config.add :administrable_menus, true

  # Connectors available in the application.
  # These connectors will be tested against the Base uhooks api
  config.add :available_connectors, [:i18n, :standard]

  # Currently enabled connector
  config.add :connector, :standard
  config.add :menu_depth, 0
  # specifies if the user can create menus
  config.add :allow_create, true
end
