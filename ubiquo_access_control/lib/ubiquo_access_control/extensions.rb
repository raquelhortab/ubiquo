module UbiquoAccessControl
  module Extensions
    autoload :Helper, 'ubiquo_access_control/extensions/helper'
    autoload :TestCase, 'ubiquo_access_control/extensions/test_case'
  end
end

Ubiquo::Extensions::UbiquoAreaController.append_helper(UbiquoAccessControl::Extensions::Helper)
ActionController::TestCase.send(:include, UbiquoAccessControl::Extensions::TestCase)
