require 'ubiquo_authentication/authenticated_system.rb'
require 'ubiquo_authentication/extensions.rb'
require 'ubiquo_authentication/ubiquo_user_console_creator.rb'
require 'ubiquo_authentication/version.rb'

Ubiquo::Extensions::UbiquoAreaController.append_include(UbiquoAuthentication::AuthenticatedSystem)
