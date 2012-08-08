# -*- encoding: utf-8 -*-

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/application.rb",  __FILE__)
require 'ubiquo/test/test_helper'

class ::Rails::Generators::TestCase
  destination File.join(Rails.root, "tmp")
  setup :prepare_destination
  setup :add_routes_file
  setup :add_navtabs_view
  teardown :destroy_destination

  protected

  def add_routes_file(file = nil)
    file ||= <<-routes
    Dummy::Application.routes.draw do
      Ubiquo::Engine.routes.draw do
        scope :ubiquo do
          # resources :articles
        end
      end
    end
    routes

    mkdir_p("#{destination_root}/config")
    File.open("#{destination_root}/config/routes.rb", 'w') { |f| f.write file }
  end

  def destroy_destination
    rm_rf(destination_root)
  end

  def add_navtabs_view
    navtabs = <<-eof
    <%
      navigator_left = create_tab_navigator(:id => "contents_tabnav", :tab_options => {}) do |navigator|
        navigator.add_tab do |tab|
          tab.text = t("application.home")
          tab.title = t("application.goto", :place => t("home"))
          tab.link = ubiquo_home_path
          tab.highlights_on({:controller => "ubiquo/home"})
          tab.highlighted_class = "active"
        end # Last tab
    %>
    <%= render_tab_navigator(navigator_right) %>
    eof

    mkdir_p("#{destination_root}/app/views/navigators")
    File.open("#{destination_root}/app/views/navigators/_main_navtabs.html.erb", 'w') do |f|
      f.write navtabs
    end
  end
end
