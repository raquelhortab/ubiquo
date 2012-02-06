# -*- encoding: utf-8 -*-

module Ubiquo
  class ScaffoldGenerator < UbiquoScaffold::Generators::Base
    class_option :run_migration,
                 desc:    "Run pending migrations at the end",
                 type:    :boolean,
                 default: false

    [:model, :controller].each do |generator|
      hook_for generator, in: :ubiquo, type: :boolean, default: true
    end

    def run_migration
      if options[:migration] && options[:run_migration]
        say_status 'migrations', 'Running pending migrations', :white
        ubiquo_migration
      end
    end
  end
end
