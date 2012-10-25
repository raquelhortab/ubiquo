# -*- encoding: utf-8 -*-

require 'ubiquo'

module UbiquoMenus
  class Engine < Rails::Engine
    include Ubiquo::Engine::Base

    paths['app/models'] << "app/models/widgets/"

    initializer :load_extensions do
      require 'ubiquo_menus/connectors'
      require 'ubiquo_menus/extensions'
      require 'ubiquo_media/version'
    end

    initializer :register_ubiquo_plugin do
      require 'ubiquo_menus/init_settings.rb'
      _loader
    end
    
    initializer :ubiquo_assets_precompile do |app|
      app.config.assets.precompile += %w(ubiquo/ubiquo_menu.*)
    end

    protected

    def _loader
      UbiquoMenus::Connectors.load!
    end

    def _config(key)
      Ubiquo::Settings.context(:ubiquo_menus).get(key).dup
    end
  end
end
