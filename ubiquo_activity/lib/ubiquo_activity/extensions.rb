module UbiquoActivity
  module Extensions
    autoload :Helper, 'ubiquo_activity/extensions/helper'
  end
end

Ubiquo::Extensions::Loader.append_include(:UbiquoController, UbiquoActivity::StoreActivity)
Ubiquo::Extensions::Loader.append_include(:UbiquoController, UbiquoActivity::RegisterActivity)

Ubiquo::Extensions::Loader.append_helper(:UbiquoController, UbiquoActivity::Extensions::Helper)
