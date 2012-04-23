# -*- encoding: utf-8 -*-

require File.join(File.dirname(__FILE__), '..', 'test_helper')
require File.join(File.dirname(__FILE__), '..', '..', 'lib/generators/ubiquo/widget/widget_generator')

class Ubiquo::WidgetGeneratorTest < ::Rails::Generators::TestCase
  tests ::Ubiquo::WidgetGenerator
  destination File.join(Rails.root, "tmp")
  setup :prepare_destination
  teardown :destroy_destination

  def destroy_destination
    rm_rf(destination_root)
  end
  protected :destroy_destination

  # -----------------------------
  # -*- model file generation -*-
  # -----------------------------
  test "should create widget model with attributes" do
    run_generator %w(Blog title:string body:text)

    assert_file 'app/models/widgets/blog.rb' do |content|
      assert_match /class Blog < Widget/, content
      assert_match /self\.allowed_options = \[:title, :body\]/, content
    end
  end

  # ----------------------------------------
  # -*- widget behaviour file generation -*-
  # ----------------------------------------
  test "should create widget behaviour with attributes" do
    run_generator %w(Blog title:string body:text)

    assert_file 'app/widgets/blog_widget.rb' do |content|
      assert_match /Widget\.behaviour :blog do \|widget\|/, content
    end
  end

  # ------------------------------
  # -*- view files generation -*-
  # ------------------------------
  test "should create views" do
    run_generator %w(Blog title:string body:text)

    assert_file "app/views/widgets/blog/ubiquo/edit.html.erb"
    assert_file "app/views/widgets/blog/show.html.erb"
  end

  # -----------------------------
  # -*- test files generation -*-
  # -----------------------------
  test "should create test files" do
    run_generator %w(Blog title:string body:text)

    assert_file 'test/unit/widgets/blog_test.rb' do |content|
      assert_match /class BlogTest < ActiveSupport::TestCase/, content
      assert_match /test "should create blog" do/, content
      assert_instance_method :create_blog, content
    end

    assert_file 'test/functional/widgets/blog_widget_test.rb' do |content|
      assert_match /class BlogWidgetTest < ActionController::TestCase/, content
      assert_match /tests PagesController/, content
      assert_match /test "blog widget should get show" do/, content
      assert_match /test "blog widget view should be as expected" do/, content
      assert_instance_method :widget_attributes, content
      assert_instance_method :create_widget, content
    end

    assert_file 'test/functional/widgets/ubiquo/blog_widget_test.rb' do |content|
      assert_match /class BlogWidgetUbiquoTest < ActionController::TestCase/, content
      assert_match /tests Ubiquo::WidgetsController/, content
      assert_match /test "edit new form" do/, content
      assert_match /test "edit form" do/, content
      assert_match /test "form submit" do/, content
      assert_instance_method :widget_attributes, content
      assert_instance_method :create_widget, content
    end
  end

  # -----------------------------
  # -*- i18n files generation -*-
  # -----------------------------
  test "should create i18n files" do
    run_generator %w(Blog title:string body:text)

    %w(ca es en).each do |locale|
      assert_file "config/locales/#{locale}/widgets/blog.yml" do |content|
        assert_match /^#{locale}:\n/, content
        assert_match /^  ubiquo:\n/, content
        assert_match /^    widgets:\n/, content
        assert_match /^      blog:\n/, content
        assert_match /^        name: "Blog"\n/, content
      end
    end
  end
end

