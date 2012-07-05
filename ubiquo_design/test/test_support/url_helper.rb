# -*- encoding: utf-8 -*-

module TestSupport
  module UrlHelper
    def self.included(base)
      base.send :include, Ubiquo::Engine.routes.url_helpers
      base.send :include, Rails.application.routes.mounted_helpers
      base.send :include, Rails.application.routes.url_helpers
    end

    def get(action, parameters = nil, session = nil, flash = nil)
      process_action(action, parameters, session, flash, "GET")
    end

    # Executes a request simulating POST HTTP method and set/volley the response
    def post(action, parameters = nil, session = nil, flash = nil)
      process_action(action, parameters, session, flash, "POST")
    end

    # Executes a request simulating PUT HTTP method and set/volley the response
    def put(action, parameters = nil, session = nil, flash = nil)
      process_action(action, parameters, session, flash, "PUT")
    end

    # Executes a request simulating DELETE HTTP method and set/volley the response
    def delete(action, parameters = nil, session = nil, flash = nil)
      process_action(action, parameters, session, flash, "DELETE")
    end

    private

    def process_action(action, parameters = nil, session = nil, flash = nil, method = "GET")
      parameters ||= {}
      process(action, parameters.merge!(:use_route => :ubiquo_design), session, flash, method)
    end

  end
end
