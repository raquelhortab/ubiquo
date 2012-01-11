module UbiquoAccessControl
  class Engine < Rails::Engine
    config.paths["lib"].autoload!

    initializer :load_extensions do
      require 'ubiquo_access_control/extensions.rb'

      Ubiquo::Extensions::Loader.append_include(:UbiquoController, UbiquoAccessControl::AccessControl)
    end

  end
end
