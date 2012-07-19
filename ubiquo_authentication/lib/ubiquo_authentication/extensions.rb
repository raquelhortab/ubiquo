module UbiquoAuthentication
  module Extensions
  end
end

:UbiquoController.helper! UbiquoAuthentication::Extensions::Helper
:UbiquoController.include! UbiquoAuthentication::Extensions::Controller
