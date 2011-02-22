module UbiquoAuthentication
  module Extensions
  end
end

Ubiquo::Extensions::UbiquoAreaController.append_helper(UbiquoAuthentication::Extensions::Helper)
Ubiquo::Extensions::UbiquoAreaController.append_include(UbiquoAuthentication::Extensions::Controller)

if Rails.env.test?
  ActionController::TestCase.send(:include, UbiquoAuthentication::Extensions::TestCase)
  ActionController::TestCase.setup(:login_as)
end
