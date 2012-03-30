# -*- encoding: utf-8 -*-

module TestSupport
  module UrlHelper
    def self.included(base)
      base.send :include, Ubiquo::Engine.routes.url_helpers
      base.send :include, Rails.application.routes.mounted_helpers
    end
  end
end
