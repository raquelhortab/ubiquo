class UbiquoController < ApplicationController

  before_filter :login_required
  layout "ubiquo/default"

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '6faa39e2a1b8aa0107b74f23f58bb636'

  def check_redirects(object, continue_params = {})
    return false if request.format.js?
    
    if params[:save_and_continue] && !object.errors.present?
      redirect_to continue_params.merge(:action => 'edit', :id => object.id)
      return true
    end
    
    return false
  end
end
