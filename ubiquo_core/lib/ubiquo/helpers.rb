require 'calendar_date_select'

module Ubiquo
  module Helpers
  end
end

Ubiquo::Extensions::Loader.append_helper(:UbiquoController, Ubiquo::Helpers::CoreUbiquoHelpers)
Ubiquo::Extensions::Loader.append_helper(:UbiquoController, Ubiquo::Helpers::ShowHelpers)
ActionController::Base.helper(Ubiquo::Helpers::CorePublicHelpers)
ActionController::Base.helper(Ubiquo::Helpers::PrototypeHelpers)
ActionController::Base.helper(Ubiquo::Helpers::RemoteHelpers)

ActionView::Helpers::FormHelper.send(:include, CalendarDateSelect::FormHelpers)
ActionView::Base.send(:include, CalendarDateSelect::FormHelpers)
ActionView::Base.send(:include, CalendarDateSelect::IncludesHelper)
