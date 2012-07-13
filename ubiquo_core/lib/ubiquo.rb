# -*- encoding: utf-8 -*-

require 'rails'
require 'prototype-rails'
require 'tinymce-rails'
require 'paperclip'

module Ubiquo

  class Engine < Rails::Engine
    module Base
      def self.included plugin
        plugin.class_eval do
          # Configure some default autoload paths
          config.paths["lib"].autoload!
          config.paths["config/locales"].glob = "**/*.{rb,yml}"

          # If the views or controllers are not found in the app (e.g. in tests),
          # the default ones will be used
          config.paths["app/views"] << "#{config.root}/install/app/views"
          config.autoload_paths << "#{config.root}/install/app/controllers"

          isolate_namespace Ubiquo

          # Define ubiquo:install task
          # Since this is inherited for every ubiquo engine, every one of them will get called
          rake_tasks do
            namespace 'ubiquo' do
              require 'ubiquo/tasks/files.rb'

              # to avoid repeated descriptions, do it only if it's ubiquo_core
              write_description = plugin.to_s == 'Ubiquo::Engine'
              desc "Install ubiquo files to the application" if write_description
              task :install do
                Ubiquo::Tasks::Files.copy_dir(Dir.glob(config.root.join('install')), "/")
              end

              namespace :install do
                desc "Install ubiquo files to the application, overwriting the existing ones" if write_description
                task :overwrite do
                  Ubiquo::Tasks::Files.copy_dir(Dir.glob(config.root.join('install')), "/", :force => true)
                end
              end

            end
          end

          # All our initializers will be run by default before the app initializers
          class << self
            def initializer_with_default_before(name, opts = {}, &blk)
              unless opts[:after] or opts[:before]
                opts[:before] = :load_config_initializers
                opts[:after]  = :load_ubiquo_core_extensions
              end
              initializer_without_default_before(name, opts, &blk)
            end
            alias_method_chain :initializer, :default_before
          end

        end
      end
    end

    initializer :load_ubiquo_core_extensions, :after => 'paperclip.insert_into_active_record' do
      require 'ubiquo/version'
      require 'ubiquo/plugin'
      require 'ubiquo/extensions'
      require 'ubiquo/filters'
      require 'ubiquo/helpers'
      require 'ubiquo/navigation_tabs'
      require 'ubiquo/navigation_links'
      require 'ubiquo/required_fields'
      require 'ubiquo/filtered_search'
      require 'ubiquo/adapters'
      require 'ubiquo/relation_selector'
      require 'ubiquo/permissions_interface'
      require 'ubiquo/init_settings.rb'
    end

    initializer :load_settings_connector do
      if Ubiquo::Plugin.registered[:ubiquo_i18n]
        Ubiquo::Settings[:settings_connector] = :i18n
      end
      Ubiquo::SettingsConnectors.load!
    end
    include Ubiquo::Engine::Base


  end

  def self.supported_locales
    Ubiquo::Settings.get :supported_locales
  end

  def self.default_locale
    Ubiquo::Settings.get :default_locale
  end
end
