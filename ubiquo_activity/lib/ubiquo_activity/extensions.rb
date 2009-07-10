module UbiquoActivity
  module Extensions
    autoload :Helper, 'ubiquo_activity/extensions/helper'
  end
end

Ubiquo::Extensions::UbiquoAreaController.append_helper(UbiquoActivity::Extensions::Helper)
