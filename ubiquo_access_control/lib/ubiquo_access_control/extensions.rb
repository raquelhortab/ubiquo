module UbiquoAccessControl
  module Extensions
  end
end

loader = Ubiquo::Extensions::Loader

loader.append_helper(:UbiquoController, UbiquoAccessControl::Extensions::Helper)
if Rails.env.test?
  ActionController::TestCase.send(:include, UbiquoAccessControl::Extensions::TestCase)
end

loader.append_include(:UbiquoUser, UbiquoAccessControl::Extensions::UbiquoUser)
