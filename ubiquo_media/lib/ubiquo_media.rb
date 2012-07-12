# -*- encoding: utf-8 -*-

require 'paperclip'
require 'ubiquo'

module UbiquoMedia
  class Engine < Rails::Engine
    include Ubiquo::Engine::Base

    initializer :load_extensions do
      # NOTE: if the paperclip extension is not loaded here, the app
      #       doesn't know where to find it
      require 'paperclip/resize_and_crop'
      require 'ubiquo_media/connectors'
      require 'ubiquo_media/extensions'
      require 'ubiquo_media/media_selector'
      require 'ubiquo_media/version'
    end

    initializer :register_ubiquo_plugin do
      require 'ubiquo_media/init_settings.rb'
    end

    initializer :add_ubiquo_form_builder_options do
      key = :ubiquo_form_builder_media_selector_tag_options
      value = Ubiquo::Settings.context(:ubiquo_media).get(key)
      Ubiquo::Helpers::UbiquoFormBuilder.initialize_method("media_selector", value)
    end

    initializer :load_connector, :after => :load_config_initializers do
      UbiquoMedia::Connectors.load!
    end
  end
end
