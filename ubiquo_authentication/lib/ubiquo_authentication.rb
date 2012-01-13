require 'ubiquo'

module UbiquoAuthentication
  class Engine < Rails::Engine
    include Ubiquo::Engine::Base

    initializer :load_extensions do
      require 'ubiquo_authentication/authenticated_system.rb'
      require 'ubiquo_authentication/extensions.rb'
      require 'ubiquo_authentication/ubiquo_user_console_creator.rb'
      require 'ubiquo_authentication/version.rb'

      Ubiquo::Extensions::Loader.append_include(:UbiquoController, UbiquoAuthentication::AuthenticatedSystem)
    end

    initializer :register_ubiquo_plugin do
      require 'ubiquo_authentication/init_settings.rb'
    end

  end
end

