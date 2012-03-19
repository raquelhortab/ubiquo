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
      _loader
    end

    protected

    def _loader
      UbiquoMedia::Connectors.load!

      key = :ubiquo_form_builder_media_selector_tag_options
      Ubiquo::Helpers::UbiquoFormBuilder.initialize_method("media_selector", _config(key))
    end

    def _config(key)
      Ubiquo::Settings.context(:ubiquo_media).get(key).dup
    end
  end
end
