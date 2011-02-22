module UbiquoAccessControl
  module Extensions
  end
end

Ubiquo::Extensions::UbiquoAreaController.append_helper(UbiquoAccessControl::Extensions::Helper)
if Rails.env.test?
  ActionController::TestCase.send(:include, UbiquoAccessControl::Extensions::TestCase)
end
