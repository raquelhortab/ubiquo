module UbiquoAccessControl
  module Extensions
  end
end

:UbiquoController.helper! UbiquoAccessControl::Extensions::Helper
if Rails.env.test?
  ActionController::TestCase.send(:include, UbiquoAccessControl::Extensions::TestCase)
end

:UbiquoUser.include! UbiquoAccessControl::Extensions::UbiquoUser
