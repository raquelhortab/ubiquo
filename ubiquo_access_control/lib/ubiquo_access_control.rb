require 'ubiquo_core'
require 'ubiquo_authentication'

module UbiquoAccessControl
  class Engine < Rails::Engine
    include Ubiquo::Engine::Base

    initializer :load_extensions do
      require 'ubiquo_access_control/extensions.rb'

      :UbiquoController.include! UbiquoAccessControl::AccessControl
    end

    initializer :register_ubiquo_plugin do
      require 'ubiquo_access_control/init_settings.rb'
    end

  end
end
