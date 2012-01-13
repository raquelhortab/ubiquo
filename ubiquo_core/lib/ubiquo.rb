module Ubiquo

  class Engine < Rails::Engine
    config.paths["lib"].autoload!
    config.autoload_paths << "#{config.root}/install/app/controllers"
    isolate_namespace Ubiquo
    initializer :load_extensions do

      require 'ubiquo/version'
      require 'ubiquo/extensions'
      require 'ubiquo/filters'
      require 'ubiquo/helpers'
      require 'ubiquo/navigation_tabs'
      require 'ubiquo/navigation_links'
      require 'ubiquo/required_fields' rescue puts $!
      require 'ubiquo/filtered_search'
      require 'ubiquo/adapters'
      require 'ubiquo/relation_selector'

      Ubiquo::Settings.add(:supported_locales, [ :ca, :es, :en ])
      Ubiquo::Settings.add(:default_locale, :ca)
    end

    initializer :register_ubiquo_plugin do
      require 'ubiquo/init_settings.rb'
    end
  end

  def self.supported_locales
    Ubiquo::Settings.get :supported_locales
  end
  def self.default_locale
    Ubiquo::Settings.get :default_locale
  end
end
