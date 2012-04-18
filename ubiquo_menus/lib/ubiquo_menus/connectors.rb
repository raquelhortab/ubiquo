module UbiquoMenus
  module Connectors
    autoload :Base, "ubiquo_menus/connectors/base"
    autoload :Standard, "ubiquo_menus/connectors/standard"

    def self.load!
      "UbiquoMenus::Connectors::#{Ubiquo::Config.context(:ubiquo_menus).get(:connector).to_s.camelize}".constantize.load!
    end
  end
end

