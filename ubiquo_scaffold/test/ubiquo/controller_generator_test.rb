# -*- encoding: utf-8 -*-

require File.join(File.dirname(__FILE__), '..', 'test_helper')
require File.join(File.dirname(__FILE__), '..', '..', 'lib/generators/ubiquo/controller/controller_generator')

class Ubiquo::ControllerGeneratorTest < ::Rails::Generators::TestCase
  tests ::Ubiquo::ControllerGenerator

  # ----------------------------------
  # -*- controller file generation -*-
  # ----------------------------------
  test "should create constroller" do
    # namespaced controller
    run_generator %w(Test::Post title:string body:text)

    assert_file 'app/controllers/ubiquo/test/posts_controller.rb' do |controller|
      assert_match /class Ubiquo::Test::PostsController < UbiquoController/, controller
      assert_match /uses_tiny_mce\(options: default_tiny_mce_options\)/, controller
      assert_instance_method :index, controller
      assert_instance_method :show, controller
      assert_instance_method :new, controller
      assert_instance_method :edit, controller
      assert_instance_method :create, controller
      assert_instance_method :update, controller
      assert_instance_method :destroy, controller
    end
  end

  test "should create constroller without tiny mce" do
    run_generator %w(Post date:date)

    assert_file 'app/controllers/ubiquo/posts_controller.rb' do |controller|
      assert_match /class Ubiquo::PostsController < UbiquoController/, controller
      assert_not_match /uses_tiny_mce\(:options => default_tiny_mce_options\)/, controller
    end
  end

  # ------------------------------
  # -*- view files generation -*-
  # ------------------------------
  test "should create views" do
    run_generator %w(Post title:string body:text published_at:date)

    assert_file 'app/views/ubiquo/posts/index.html.erb'
    assert_file 'app/views/ubiquo/posts/edit.html.erb'
    assert_file 'app/views/ubiquo/posts/new.html.erb'
    assert_file 'app/views/ubiquo/posts/show.html.erb'
    assert_file 'app/views/ubiquo/posts/_post.html.erb'
    assert_file 'app/views/ubiquo/posts/_form.html.erb'
    assert_file 'app/views/ubiquo/posts/_submenu.html.erb'
    assert_file 'app/views/ubiquo/posts/_title.html.erb'
    assert_file 'app/views/navigators/_posts_navlinks.html.erb'
  end

  test "should create helper" do
    run_generator %w(Post title:string body:text published_at:date)

    assert_file 'app/helpers/ubiquo/posts_helper.rb' do |helper|
      assert_match /^module Ubiquo::PostsHelper$/, helper
      assert_instance_method :post_filters, helper do |filter|
        assert_match /f\.text/, filter
        # published_at attribute
        assert_match /f\.date/, filter
      end
      assert_instance_method :post_list, helper
      assert_instance_method :post_actions, helper
    end
  end

  # ---------------------------------------
  # -*- functional test file generation -*-
  # ---------------------------------------
  test "should create functional test" do
    run_generator %w(Post title:string body:text published_at:date)

    assert_file 'test/functional/ubiquo/posts_controller_test.rb' do |content|
      assert_match /test "should get index" do/, content
      assert_match /test "should get new" do/, content
      assert_match /test "should get show" do/, content
      assert_match /test "should create post" do/, content
      assert_match /test "should get edit" do/, content
      assert_match /test "should update post" do/, content
      assert_match /test "should destroy post" do/, content
      assert_instance_method :post_attributes, content
      assert_instance_method :create_post, content
    end
  end

  # ---------------------------------------
  # -*- helper test file generation -*-
  # ---------------------------------------
  test "should create helper test" do
    run_generator %w(Post title:string body:text published_at:date)

    assert_file 'test/unit/helpers/ubiquo/posts_helper_test.rb' do |content|
      assert_match /class Ubiquo::PostsHelperTest < ActionView::TestCase/, content
      assert_match /end/, content
    end
  end

  # -----------------------------
  # -*- i18n files generation -*-
  # -----------------------------
  test "should create traslation files" do
    run_generator %w(Post title:string body:text published_at:date)

    %w(ca es en).each do |locale|
      assert_file "config/locales/#{locale}/ubiquo/post.yml" do |content|
        assert_match /^#{locale}:/, content
        assert_match /^  ubiquo:/, content
        assert_match /^    post:/, content
        assert_match /title: "Posts"/, content
        assert_match /created:/, content
        assert_match /create_error:/, content
        assert_match /edited:/, content
        assert_match /edit_error:/, content
        assert_match /destroyed:/, content
        assert_match /destroy_error:/, content
        assert_match /index:/, content
        assert_match /new:/, content
        assert_match /edit:/, content
        assert_match /empty_list_title:/, content
        assert_match /empty_list_message:/, content
      end
    end
  end

  # -------------------------
  # -*- routes generation -*-
  # -------------------------
  test "should generate routes" do
    run_generator %w(Post title:string body:text published_at:date)

    assert_file 'config/routes.rb' do |routes|
      assert_match /namespace\(:ubiquo\) { resources :posts }/, routes
    end
  end

  test "should generate namespaced routes" do
    run_generator %w(Blog::Post title:string body:text published_at:date)

    assert_file 'config/routes.rb' do |routes|
      assert_match /namespace\(:ubiquo\) { namespace\(:blog\) { resources :posts } }/, routes
    end
  end
end
