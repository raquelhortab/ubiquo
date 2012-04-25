Dir.glob(File.join(File.dirname(__FILE__), "extensions/*.rb")) do |c|
  require c
end

ActionController::Base.helper(UbiquoMenus::Extensions::Helper)
ActionView::Base.send(:include, UbiquoMenus::Extensions::Helper)

ActionController::Base.helper(UbiquoMenus::Extensions::MenuSelectionResolver)
ActionView::Base.send(:include, UbiquoMenus::Extensions::MenuSelectionResolver)

UbiquoController.helper(UbiquoMenus::Extensions::Ubiquo::Helper)

# should be inject in pages_controller but the ubiquo_design loads afters this call
UbiquoController.helper(UbiquoMenus::Extensions::Ubiquo::Widgets::MenuWidgetHelper)
