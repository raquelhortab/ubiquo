class UbiquoController < ApplicationController

  before_filter :login_required
  layout "ubiquo/default"

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '6faa39e2a1b8aa0107b74f23f58bb636'

end
