require 'ubiquo_access_control/extensions.rb'

Ubiquo::Extensions::UbiquoAreaController.append_include(UbiquoAccessControl::AccessControl)
