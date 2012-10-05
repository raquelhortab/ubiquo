require 'ubiquo'

module UbiquoCategories
  class Engine < Rails::Engine
    include Ubiquo::Engine::Base

    initializer :load_extensions do
      require 'ubiquo_categories/connectors'
      require 'ubiquo_categories/extensions.rb'
      require 'ubiquo_categories/exceptions.rb'
      require 'ubiquo_categories/category_selector.rb'
      require 'ubiquo_categories/filters.rb'
      require 'ubiquo_categories/version.rb'
    end

    initializer :register_ubiquo_plugin do
      require 'ubiquo_categories/init_settings.rb'
    end

    initializer :load_connector, :after => :load_config_initializers do
      UbiquoCategories::Connectors.load!
    end

  end
end
