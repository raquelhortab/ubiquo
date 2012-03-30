# -*- encoding: utf-8 -*-

require 'ubiquo'

module UbiquoDesign
  class Engine < Rails::Engine
    include Ubiquo::Engine::Base

    initializer :load_extensions do
      require 'ubiquo_design/extensions'
      require 'ubiquo_design/ubiquo_widgets'
      require 'ubiquo_design/render_page'
      require 'ubiquo_design/version'
      require 'ubiquo_design/cache_managers/base'
      require 'ubiquo_design/cache_expiration'
      require 'ubiquo_design/cache_rendering'
    end

    initializer :register_ubiquo_plugin do
      require 'ubiquo_design/init_settings.rb'
      _loader
    end

    protected

    def _loader
      UbiquoDesign::Connectors.load!

      ActionController::Base.send(:include, UbiquoDesign::UbiquoWidgets)
      if ActionController::Base.perform_caching
        ActionController::Base.send(:include, UbiquoDesign::CacheRendering)
        ActiveRecord::Base.send(:include, UbiquoDesign::CacheExpiration::ActiveRecord)
      end
    end
  end
end
