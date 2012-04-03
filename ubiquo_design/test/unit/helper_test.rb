require File.dirname(__FILE__) + '/../test_helper'

class UbiquoDesign::Extensions::HelperTest < ActionView::TestCase

  test 'url_for_page given a page' do
    page = pages(:one_design)
    mock_url_for(page.url_name) do
      url_for_page(page)
    end
  end

  test 'url_for_page given a key' do
    page = pages(:one_design)
    mock_url_for(page.url_name) do
      url_for_page(page.key)
    end
  end

  test 'link_to_page relies in url_for_page' do
    caption = 'caption'
    page_key = pages(:one_design).key
    url_for_options = {:controller => '/pages'}
    link_to_options = {:class => 'example'}

    self.expects(:url_for_page).with(page_key, url_for_options).returns('url')
    self.expects(:link_to).with(caption, 'url', link_to_options)

    link_to_page(caption, page_key, url_for_options, link_to_options)
  end

  test 'url_for_page does not encode slashes' do
    page = Page.new(:url_name => 'with/slash')

    assert url_for_page(page) =~ /with\/slash/
  end

  test 'url_for_page with page param' do
    page = pages(:one_design)

    assert_match /#{page.url_name}\/page\/2$/, url_for_page(page, :page => 2)
  end

  test 'url_for_page with custom params' do
    page = pages(:one_design)

    assert_match /#{page.url_name}\?test=2$/, url_for_page(page, :test => 2)
  end

  test 'url_for_page with url param concatenates to the url' do
    page = pages(:one_design)
    assert_match /#{page.url_name}\/my\/params/, url_for_page(page, :url => 'my/params')
  end

  private

  def mock_url_for(url)
    app_routes = Rails.application.routes
    app_routes.expects(:url_for).with do |options|
      options[:controller] = '/pages'
      options[:action] = 'show'
      options[:url] = url
    end

    yield
  ensure
    app_routes.unstub(:url_for)
  end

end
