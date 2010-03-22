module Ubiquo
  # -- UBIQUO_PLUGINS should be controlled by profile
  # -- appname must be provided by opts[:app_name]
  # TODO: exception_recipient must be provided by ? (default?)
  # TODO: sender_adress must be provided by ? (default?)
  # -- choosen_adapter must be provided by opts[:database] (sqlite is sqlite3 in tpls)
  # -- PROBLEM: routes only profile plugins should add to routes.
  # TODO: IMPROVEMENT RAILS_GEM_VERSION could be set in options
  # -- :branch parameter in add_plugins should be set using opts[:template]
  class Generator

    attr_reader :opts, :tpl_skeleton, :rails_template
    
    def initialize(opts, tpl_skeleton)
      @opts, @tpl_skeleton = opts, tpl_skeleton
    end

    def build_rails_template
      template = ERB.new(File.read(@tpl_skeleton), 0, "%<>")
      @rails_template = template.result(binding)
    end
  end
end
