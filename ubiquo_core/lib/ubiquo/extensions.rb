# -*- encoding: utf-8 -*-

module Ubiquo::Extensions
end

# It's good to put this one the first, to avoid potential problems in the other extensions
Module.send(:include, Ubiquo::Extensions::Module)

:UbiquoController.include! Ubiquo::Extensions::DateParser
ActionView::Base.field_error_proc = Ubiquo::Extensions::ActionView.ubiquo_field_error_proc
ActiveRecord::Base.send(:extend, Ubiquo::Extensions::ActiveRecord)

Object.send(:include, Ubiquo::Extensions::ObjectMethods)
Proc.send(:include, Ubiquo::Extensions::Proc)
Array.send(:include, Ubiquo::Extensions::Array)
String.send(:include, Ubiquo::Extensions::String)

if Rails.env.test?
  require 'action_controller/test_case'
  ActiveSupport::TestCase.send(:include, Ubiquo::Extensions::TestCase)
  ActionController::TestCase.send(:include, Ubiquo::Extensions::TestCase)
  ActionController::TestCase.send(:include, Ubiquo::Extensions::TestCase::EngineUrlHelper)
end

ActiveRecord::Base.send(:include, Ubiquo::Extensions::ConfigCaller)
ActiveRecord::Base.send(:extend, Ubiquo::Extensions::ConfigCaller)
ActiveRecord::SpawnMethods.send(:include, Ubiquo::Extensions::DistinctOption)
:UbiquoController.include! Ubiquo::Extensions::ConfigCaller
:UbiquoController.extend! Ubiquo::Extensions::ConfigCaller
ActionView::Base.send(:include, Ubiquo::Extensions::ConfigCaller)
ActionView::Base.send(:extend, Ubiquo::Extensions::ConfigCaller)


ActionController::Base.helper(Ubiquo::Extensions::Helper)
ActionView::Base.send(:include, Ubiquo::Extensions::Helper)

ActionController::Base.send(:include, Ubiquo::Extensions::RespondsToParent)
