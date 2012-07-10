require File.dirname(__FILE__) + "/../../../test_helper.rb"

include RoutingFilter

class SomeController < ActionController::Base
  def index; end
  def other; end
end
class Ubiquo::SomeController < ActionController::Base
  def index; end
  def other; end
end

# test based on the local_filter test from the gem routing-filter
class UbiquoLocaleTest < Test::Unit::TestCase
  attr_reader :routes, :ubiquo_params, :public_params

  def setup
    RoutingFilter.active = true
    Locale.delete_all
    %w(en es ca).each do |locale|
      create_locale :iso_code   => locale,
                    :is_active  => true,
                    :is_default => true
    end

    @ubiquo_params = { :controller => 'ubiquo/some', :action => 'index' }
    @public_params = { :controller => 'some', :action => 'index' }

    @routes = draw_routes do
      filter :ubiquo_locale
      match 'ubiquo',             :to => 'ubiquo/some#index'
      match 'ubiquo/other',       :to => 'ubiquo/some#other'
      match '/dashboard/:locale', :to => 'some#index'
      match '/other',             :to => 'some#other'
    end
  end

  def teardown
    RoutingFilter.active = false
  end

  def test_should_recognize_localized_routes_inside_ubiquo_area
    Locale.active.map(&:to_s).each do |locale|
      expected = ubiquo_params.merge(:locale => locale)
      result   = routes.recognize_path("/ubiquo/#{locale}")
      assert_equal expected, result

      expected = ubiquo_params.merge(:action => 'other', :locale => locale)
      result   = routes.recognize_path("/ubiquo/#{locale}/other")
      assert_equal expected, result
    end
  end

  def test_should_generate_localized_routes_inside_ubiquo_area
    Locale.active.map(&:to_s).each do |locale|
      expected = "/ubiquo/#{locale}"
      result   = routes.generate(ubiquo_params.merge(:locale => locale))
      assert_equal expected, result.first

      expected = "/ubiquo/#{locale}/other"
      result   = routes.generate(ubiquo_params.merge(:locale => locale, :action => 'other'))
      assert_equal expected, result.first
    end
  end

  def test_should_recognize_routes_outside_ubiquo_area
    Locale.active.map(&:to_s).each do |locale|
      expected = public_params.merge(:locale => locale)
      result   = routes.recognize_path("/dashboard/#{locale}")
      assert_equal expected, result
    end

    expected = public_params.merge(:action => 'other')
    result   = routes.recognize_path("/other")
    assert_equal expected, result
  end

  def test_should_generate_routes_outside_ubiquo_area
    Locale.active.map(&:to_s).each do |locale|
      expected = "/dashboard/#{locale}"
      result   = routes.generate(public_params.merge(:locale => locale))
      assert_equal expected, result.first
    end

    expected = "/other"
    result   = routes.generate(public_params.merge(:action => 'other'))
    assert_equal expected, result.first
  end

  protected

  def draw_routes(&block)
    ActionDispatch::Routing::RouteSet.new.tap { |set| set.draw(&block) }
  end

end
