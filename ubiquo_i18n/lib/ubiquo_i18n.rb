require 'ubiquo'

module UbiquoI18n
  class Engine < Rails::Engine
    include Ubiquo::Engine::Base

    initializer :load_extensions do
      require 'ubiquo_i18n/extensions.rb'
      require 'ubiquo_i18n/filters.rb'
      require 'ubiquo_i18n/schema_dumper.rb'
      require 'ubiquo_i18n/adapters.rb'
      require 'ubiquo_i18n/version.rb'
      require 'ubiquo_i18n/routing_filters.rb'
    end

    initializer :register_ubiquo_plugin do
      require 'ubiquo_i18n/init_settings.rb'
    end

    initializer :load_locale, :after => :load_config_initializers do
      Locale.current = Locale.default if Locale.table_exists?
    end
    
    initializer :ubiquo_assets_precompile do |app|
      app.config.assets.precompile += %w(ubiquo/ubiquo_i18n.js)
    end

  end
end

