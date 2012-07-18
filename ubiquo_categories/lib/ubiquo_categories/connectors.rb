module UbiquoCategories
  module Connectors

    require 'ubiquo_categories/connectors/base'

    def self.load!
      "UbiquoCategories::Connectors::#{Ubiquo::Settings[:ubiquo_categories][:connector].to_s.camelize}".constantize.load!
    end
  end
end
