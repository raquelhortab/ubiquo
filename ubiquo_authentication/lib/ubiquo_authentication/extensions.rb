module UbiquoAuthentication
  module Extensions
    autoload :Helper, 'ubiquo_authentication/extensions/helper'
    autoload :TestCase, 'ubiquo_authentication/extensions/test_case'
    autoload :Controller, 'ubiquo_authentication/extensions/controller'
  end
end

Ubiquo::Extensions::UbiquoAreaController.append_helper(UbiquoAuthentication::Extensions::Helper)
Ubiquo::Extensions::UbiquoAreaController.append_include(UbiquoAuthentication::Extensions::Controller)
ActionController::TestCase.send(:include, UbiquoAuthentication::Extensions::TestCase)
ActionController::TestCase.setup(:login_as)
