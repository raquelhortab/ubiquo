require 'ubiquo_access_control/access_control.rb'
require 'ubiquo_access_control/extensions.rb'
require 'ubiquo_access_control/version.rb'

ActionController::Base.send(:include, UbiquoAccessControl::AccessControl)
