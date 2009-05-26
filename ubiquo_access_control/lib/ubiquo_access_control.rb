require 'ubiquo_access_control/access_control.rb'
require 'ubiquo_access_control/extensions.rb'
require 'ubiquo_access_control/version.rb'

Ubiquo::Extensions::UbiquoAreaController.append_include(UbiquoAccessControl::AccessControl)
