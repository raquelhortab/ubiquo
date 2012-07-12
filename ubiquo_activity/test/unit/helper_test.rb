require File.dirname(__FILE__) + "/../test_helper.rb"

class UbiquoActivity::Extensions::HelperTest < ActionView::TestCase

  helper UbiquoActivity::Extensions::Helper

  def test_ubiquo_activities_link
    expects(:ubiquo_config_call).returns(true) # gives it permission
    ubiquo_activities_link(Ubiquo::NavigationLinks::NavigatorLinks.new)
  end

end
