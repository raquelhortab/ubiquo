require 'ubiquo'

module UbiquoAuthentication
  class Engine < Rails::Engine
    include Ubiquo::Engine::Base

    initializer :load_extensions do
      require 'ubiquo_authentication/authenticated_system.rb'
      require 'ubiquo_authentication/extensions.rb'
      require 'ubiquo_authentication/ubiquo_user_console_creator.rb'
      require 'ubiquo_authentication/version.rb'

      :UbiquoController.include! UbiquoAuthentication::AuthenticatedSystem
    end

    initializer :register_ubiquo_plugin do
      require 'ubiquo_authentication/init_settings.rb'
    end
    
    initializer :ubiquo_assets_precompile do |app|
      app.config.assets.precompile += %w(ubiquo/login.css)
    end

  end
end

