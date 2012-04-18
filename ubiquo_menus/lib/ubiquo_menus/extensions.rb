module UbiquoMenus
  module Extensions
    autoload :Helper, "ubiquo_menus/extensions/helper"
  end
end

ActionController::Base.helper(UbiquoMenus::Extensions::Helper)
ActionView::Base.send(:include, UbiquoMenus::Extensions::Helper)
