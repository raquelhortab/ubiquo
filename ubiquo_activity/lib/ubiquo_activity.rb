# -*- encoding: utf-8 -*-

require 'ubiquo'
require 'ubiquo_authentication'

module UbiquoActivity
  class Engine < Rails::Engine
    include Ubiquo::Engine::Base

    initializer :load_extensions do
      require 'ubiquo_activity/extensions'
      require 'ubiquo_activity/store_activity'
      require 'ubiquo_activity/register_activity'
      require 'ubiquo_activity/version'
    end

    initializer :register_ubiquo_plugin do
      require 'ubiquo_activity/init_settings'
    end

    protected

  end
end
