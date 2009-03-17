require 'ubiquo_authentication/authenticated_system.rb'
require 'ubiquo_authentication/extensions.rb'
require 'ubiquo_authentication/version.rb'

ActionController::Base.send(:include, UbiquoAuthentication::AuthenticatedSystem)
