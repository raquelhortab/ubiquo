require File.dirname(__FILE__) + "/../../../test_helper.rb"

include RoutingFilter
class Ubiquo::SomeController < ActionController::Base
  def index; end
  def other; end
  def stuff; end
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

    @routes = draw_routes do
      filter :ubiquo_locale
      match '/', :to => 'ubiquo/some#index'
      match 'other', :to => 'ubiquo/some#other'
      match 'ubiquo_stuff', :to => 'ubiquo/some#stuff'
      match '/dashboard/:locale', :to => 'some#index'
      match '/other', :to => 'some#other'
    end
  end

  def teardown
    RoutingFilter.active = false
  end

  def test_should_recognize_localized_routes_inside_ubiquo_area
    Locale.active.map(&:to_s).each do |locale|
      expected = ubiquo_params.merge(:locale => locale)
      result   = routes.recognize_path("/#{locale}")
      assert_equal expected, result

      expected = ubiquo_params.merge(:action => 'other', :locale => locale)
      result   = routes.recognize_path("/#{locale}/other")
      assert_equal expected, result
    end
  end

  def test_should_generate_localized_routes_inside_ubiquo_area
    Locale.active.map(&:to_s).each do |locale|
      expected = "/#{locale}"
      result   = routes.generate(ubiquo_params.merge(:locale => locale))
      assert_equal expected, result.first

      expected = "/#{locale}/other"
      result   = routes.generate(ubiquo_params.merge(:locale => locale, :action => 'other'))
      assert_equal expected, result.first
    end
  end

  def test_should_generate_correct_routes_for_controller_containing_ubiquo
    locale = Locale.default
    expected = "/en/ubiquo_stuff"
    result   = routes.generate(ubiquo_params.merge(:locale => locale, :action => 'stuff'))
    assert_equal expected, result.first
  end

  def test_should_recognize_correct_routes_for_controller_containing_ubiquo
    locale = Locale.default
    expected = ubiquo_params.merge(:locale => locale, :action => 'stuff')
    Object.const_set :AAA, true
    result   = routes.recognize_path("/en/ubiquo_stuff")
    assert_equal expected, result
  end

  protected

  def draw_routes(&block)
    ActionDispatch::Routing::RouteSet.new.tap { |set| set.draw(&block) }
  end

end
