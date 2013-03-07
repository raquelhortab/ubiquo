require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require
require 'ubiquo_core'

module Dummy
  class Application < Rails::Application
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Default in Rails 3.2.3, so it should be supported
    config.active_record.whitelist_attributes = true

    # Remove any previous initializer and other files that can have been placed
    # in other ubiquo gems testing
    initializer :clean_environment, :before => :load_config_initializers do

      # delete initializers (except unified_init.rb)
      to_delete = Dir[File.expand_path('../initializers', __FILE__) + '/*.rb']
      FileUtils.rm to_delete.reject{|f| f =~ /unified_init/}

      # delete all files in app (the needed ones will be reinstalled)
      # leave application_XXX (helper or controller) since then are installed by rails
      app_to_delete = Dir[File.expand_path('../../app/', __FILE__)+ '/**/*.rb']
      FileUtils.rm app_to_delete.reject{|f| f =~ /application_/}

      # delete all migrations (the needed ones will be reinstalled)
      FileUtils.rm Dir[File.expand_path('../../db/migrate', __FILE__)+ '/**/*.rb']
    end
  end
end
