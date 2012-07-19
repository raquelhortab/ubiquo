require 'calendar_date_select'

module Ubiquo
  module Helpers
  end
end

:UbiquoController.helper! Ubiquo::Helpers::CoreUbiquoHelpers
:UbiquoController.helper! Ubiquo::Helpers::ShowHelpers
ActionController::Base.helper(Ubiquo::Helpers::CorePublicHelpers)
ActionController::Base.helper(Ubiquo::Helpers::RemoteHelpers)

ActionView::Helpers::FormHelper.send(:include, CalendarDateSelect::FormHelpers)
ActionView::Base.send(:include, CalendarDateSelect::FormHelpers)
ActionView::Base.send(:include, CalendarDateSelect::IncludesHelper)
