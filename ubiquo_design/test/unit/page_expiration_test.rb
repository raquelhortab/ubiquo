require File.dirname(__FILE__) + "/../test_helper.rb"
require 'ruby-debug'

class PageExpirationTest < ActiveSupport::TestCase
  unless ActionController::Base.included_modules.include? UbiquoDesign::CacheRendering
    ActionController::Base.send(:include, UbiquoDesign::CacheRendering)
  end

  unless ActiveRecord::Base.included_modules.include? UbiquoDesign::CacheExpiration::ActiveRecord
    ActiveRecord::Base.send(:include, UbiquoDesign::CacheExpiration::ActiveRecord)
  end

  def test_should_expire_page_on_destroy
    page = create_page
    caching_on
    UbiquoDesign.cache_manager.expects(:expire_by_model).once.with(page, nil).returns(true)
    UbiquoDesign.cache_manager.expects(:expire_by_model).twice.returns(true)
    page.destroy
  end

  def test_should_expire_page_on_save
    page = create_page
    caching_on
    UbiquoDesign.cache_manager.expects(:expire_by_model).once.with(page, nil).returns(true)
    page.save
  end

  [:client, :server].map do |type|
    expiration_type = "#{type}_expiration"

    test "should_set_#{expiration_type}" do
      page = create_page(expiration_type => 10.hours)
      assert_equal 10.hours, page.send(expiration_type)
    end

    test "should_set_default_#{expiration_type}_if_none" do
      page = create_page
      assert_equal Ubiquo::Settings[:ubiquo_design][:page_ttl][type][:default], page.send(expiration_type)
    end

    test "should_set_minimum_#{expiration_type}_if_too_low" do
      setting = Ubiquo::Settings[:ubiquo_design][:page_ttl]
      old_min = setting[type][:minimum]
      setting[type][:minimum] = 2.seconds
      page = create_page(expiration_type => 1.second)
      assert_equal setting[type][:minimum], page.send(expiration_type)
      setting[type][:minimum] = old_min
    end
  end

  def test_should_expire_page
    caching_on
    page = create_page
    UbiquoDesign.cache_manager.expects(:expire_page).with(page).returns(true)
    page.expire
  end

  def test_should_expire_selected_pages
    caching_on
    pages = [create_page, create_page(:url_name => 'other')]
    UbiquoDesign.cache_manager.expects(:expire_page).with(pages.first).returns(true)
    UbiquoDesign.cache_manager.expects(:expire_page).with(pages.last).returns(true)
    Page.expire(pages.map(&:id))

    UbiquoDesign.cache_manager.expects(:expire_page).with(pages.first).returns(true)
    UbiquoDesign.cache_manager.expects(:expire_page).with(pages.last).returns(true)
    Page.expire(pages)
  end

  # FIXME as integration?
  def test_should_expire_all_pages
    UbiquoDesign.cache_manager.expects(:ban).once
    Page.expire_all
  end

  def test_should_expire_url
    url = 'http://www.mywebsite.com'
    UbiquoDesign.cache_manager.expects(:expire_url).with(url).returns(true)
    Page.expire_url url
  end

  # creates a (draft) page
  def create_page(options = {})
    Page.create({
      :name          => "Custom page",
      :url_name      => "custom_page",
      :page_template => "static",
      :published_id  => nil,
      :is_modified   => true
    }.merge(options))
  end

  def test_should_be_expirable_by_a_superadmin
    # FIXME refactor this inside ubiquo_core's helper
    original = Ubiquo::Settings[:ubiquo_design][:page_can_be_expired?]
    begin
      Ubiquo::Settings[:ubiquo_design][:page_can_be_expired?] = lambda { false }
      user = mock('user')
      user.stubs(:is_superadmin?).returns(true)
      page = create_page
      assert page.can_be_expired_by?(user)
    rescue
      Ubiquo::Settings[:ubiquo_design][:page_can_be_expired?] = original
    end
  end

  def test_should_be_expirable_by_a_user_using_setting
    # FIXME refactor this inside ubiquo_core's helper
    begin
      original = Ubiquo::Settings[:ubiquo_design][:page_can_be_expired?]
      user = mock('user')
      user.stubs(:is_superadmin?).returns(false)
      user.stubs(:is_admin?).returns(true)
      page = create_page
      called = false
      Ubiquo::Settings[:ubiquo_design][:page_can_be_expired?] = lambda do |_page, _user|
        assert_equal page, _page
        assert_equal user, _user
        called = true
        false
      end
      assert !page.can_be_expired_by?(user)
      assert called
    ensure
      Ubiquo::Settings[:ubiquo_design][:page_can_be_expired?] = original
    end
  end

  private

  def create_example_structure
    unless @structure_created
      UbiquoDesign::Structure.define do
        page_template :example, :layout => 'test_layout' do
          block :one do
            widget :one
          end
          block :two do
            widget :two
          end
          widget :example
        end
        widget :global
      end
      @structure_created = true
    end
  end

  def caching_on
    ActionController::Base.stubs(:perform_caching).returns(true)
  end

end
