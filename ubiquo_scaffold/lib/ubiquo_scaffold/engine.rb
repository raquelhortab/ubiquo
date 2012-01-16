# -*- encoding: utf-8 -*-

require 'rails'
require 'ubiquo_scaffold'

module UbiquoScaffold
  class Engine < Rails::Engine
    engine_name :ubiquo_scaffold

    load_tasks
  end
end
