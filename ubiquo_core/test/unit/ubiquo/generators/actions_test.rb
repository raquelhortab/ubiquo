# -*- encoding: utf-8 -*-

require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class StubGenerator < ::Rails::Generators::Base
  include Ubiquo::Generators::Actions

  def do_nothing; end
end

# Tests based on the official Rails::Generators::Actions module
# @link: https://github.com/rails/rails/blob/master/railties/test/generators/actions_test.rb
class Ubiquo::Generators::ActionsTests < ::Rails::Generators::TestCase
  tests ::StubGenerator
  setup :add_routes_file

  def test_should_add_tab
    add_navtabs_view
    action :ubiquo_tab, 'stubs'

    assert_file 'app/views/navigators/_main_navtabs.html.erb' do |tabs|
      assert_match /end$/, tabs
      assert_match /navigator\.add_tab do |tab|/, tabs
      assert_match /tab\.text  = t\('ubiquo\.stub\.title'\)/, tabs
      assert_match /tab\.title = t\('application\.goto', :place => 'stubs'\)/, tabs
      assert_match /tab\.link  = ubiquo_stubs_path/, tabs
      assert_match /tab\.highlights_on\(:controller => 'ubiquo\/stubs'\)/, tabs
      assert_match /tab\.highlighted_class = 'active'/, tabs
      assert_match /end # Last tab$/, tabs
    end
  end

  def test_should_run_ubiquo_migration
    generator.expects(:run).once.with("rake db:migrate RAILS_ENV=development", :verbose => false)
    old_env, ENV['RAILS_ENV'] = ENV["RAILS_ENV"], nil
    action :ubiquo_migration
  ensure
    ENV["RAILS_ENV"] = old_env
  end

  def test_should_add_one_ubiquo_route_resource
    action :ubiquo_route_resources, 'stubs'

    assert_file 'config/routes.rb' do |routes|
      assert_match /scope :ubiquo do$/, routes
      assert_match /resources :stubs$/, routes
    end
  end

  def test_should_add_multiple_ubiquo_route_resources
    action :ubiquo_route_resources, 'tests', 'posts'

    assert_file 'config/routes.rb' do |routes|
      assert_match /scope :ubiquo do$/, routes
      assert_match /resources :tests, :posts$/, routes
    end
  end

  def test_should_add_one_nested_route_resource_inside_a_parent_with_children
    add_routes_file <<-routes
    Dummy::Application.routes.draw do
      Ubiquo::Engine.routes.draw do
        scope :ubiquo do
          resource :root do
            resources :tests
          end
        end
      end
    end
    routes

    action :nested_route_resources, 'root', 'stubs'

    assert_file 'config/routes.rb' do |routes|
      assert_match /scope :ubiquo do$/, routes
      assert_match /resource :root do$/, routes
      assert_match /resources :stubs$/, routes
      assert_match /resources :tests$/, routes
    end
  end

  def test_should_add_multiple_nested_route_resources_inside_a_parent_with_children
    add_routes_file <<-routes
    Dummy::Application.routes.draw do
      Ubiquo::Engine.routes.draw do
        scope :ubiquo do
          resource :root do
            resources :tests
          end
        end
      end
    end
    routes

    action :nested_route_resources, 'root', 'stubs', 'mocks'

    assert_file 'config/routes.rb' do |routes|
      assert_match /scope :ubiquo do$/, routes
      assert_match /resource :root do$/, routes
      assert_match /resources :stubs, :mocks$/, routes
      assert_match /resources :tests$/, routes
    end
  end

  def test_should_add_one_nested_route_resource_inside_a_parent_without_children
    add_routes_file <<-routes
    Dummy::Application.routes.draw do
      Ubiquo::Engine.routes.draw do
        scope :ubiquo do
          resource :root
        end
      end
    end
    routes

    action :nested_route_resources, 'root', 'stubs'

    assert_file 'config/routes.rb' do |routes|
      assert_match /scope :ubiquo do$/, routes
      assert_match /resource :root do$/, routes
      assert_match /resources :stubs$/, routes
    end
  end

  def test_should_add_multiple_nested_route_resources_inside_a_parent_without_children
    add_routes_file <<-routes
    Dummy::Application.routes.draw do
      Ubiquo::Engine.routes.draw do
        scope :ubiquo do
          resource :root
        end
      end
    end
    routes

    action :nested_route_resources, 'root', 'stubs', 'mocks'

    assert_file 'config/routes.rb' do |routes|
      assert_match /scope :ubiquo do$/, routes
      assert_match /resource :root do$/, routes
      assert_match /resources :stubs, :mocks$/, routes
    end
  end

  private

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

  def add_routes_file(file = nil)
    file ||= <<-routes
    Dummy::Application.routes.draw do
      Ubiquo::Engine.routes.draw do
        scope :ubiquo do
          # all the resources under ubiquo should be declared here:
          # resources :articles
        end
      end
    end
    routes

    mkdir_p("#{destination_root}/config")
    File.open("#{destination_root}/config/routes.rb", 'w') { |f| f.write file }
  end

  def action(*args, &block)
    silence(:stdout){ generator.send(*args, &block) }
  end
end
