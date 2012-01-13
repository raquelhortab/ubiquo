module UbiquoScaffold

  class Engine < Rails::Engine
    config.paths["lib"].autoload!
    config.autoload_paths << "#{config.root}/install/app/controllers"

    initializer :load_extensions do
      require 'ubiquo_scaffold/version'
      require 'ubiquo_scaffold/translation_updater'
      require 'ubiquo_scaffold/commands'
    end
  end
end