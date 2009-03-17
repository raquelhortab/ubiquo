module UbiquoAuthentication
  module Extensions
    autoload :Helper, 'ubiquo_authentication/extensions/helper'
    autoload :TestCase, 'ubiquo_authentication/extensions/test_case'
  end
end

ActionController::Base.helper(UbiquoAuthentication::Extensions::Helper)
ActionController::TestCase.send(:include, UbiquoAuthentication::Extensions::TestCase)
ActionController::TestCase.setup(:login_as)
