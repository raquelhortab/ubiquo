module UbiquoMenus
  module Connectors
    def self.load!
      "UbiquoMenus::Connectors::#{Ubiquo::Config.context(:ubiquo_menus).get(:connector).to_s.camelize}".constantize.load!
    end
  end
end

Dir.glob(File.join(File.dirname(__FILE__), "connectors/*.rb")) do |c|
  require c
end

