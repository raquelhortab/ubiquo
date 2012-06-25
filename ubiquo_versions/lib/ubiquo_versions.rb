module UbiquoVersions

  class Engine < Rails::Engine
    config.paths["lib"].autoload!

    initializer :load_extensions do
      require 'ubiquo_versions/adapters.rb'
      require 'ubiquo_versions/schema_dumper.rb'
      require 'ubiquo_versions/extensions.rb'
      require 'ubiquo_versions/version.rb'
    end
  end
end
