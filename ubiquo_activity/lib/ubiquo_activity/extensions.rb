module UbiquoActivity
  module Extensions
    autoload :Helper, 'ubiquo_activity/extensions/helper'
  end
end

:UbiquoController.include! UbiquoActivity::StoreActivity
:UbiquoController.include! UbiquoActivity::RegisterActivity

:UbiquoController.helper! UbiquoActivity::Extensions::Helper
