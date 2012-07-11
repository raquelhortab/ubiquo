require 'ubiquo_core'

module UbiquoVersions

  class Engine < Rails::Engine
    include Ubiquo::Engine::Base

    initializer :load_extensions do
      require 'ubiquo_versions/extensions.rb'
      require 'ubiquo_versions/version.rb'
    end
  end
end
