class Ubiquo::SessionsController < ApplicationController
  
  include Ubiquo::Extensions::UbiquoAreaController
  
  #shows the login form
  def new
    if logged_in?
      redirect_to ubiquo_home_path
    end
  end

  # login method. If OK, redirects to expected path or ubiquo_home.
  def create
    self.current_ubiquo_user = UbiquoUser.authenticate(params[:login],
                                                       params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_ubiquo_user.remember_me
        cookies[:auth_token] = {
          :value => self.current_ubiquo_user.remember_token ,
          :expires => self.current_ubiquo_user.remember_token_expires_at
        }
      end
      redirect_back_or_default(ubiquo_home_path)
      flash[:notice] = t 'ubiquo.auth.login_success'
    else
      flash[:error] = t 'ubiquo.auth.login_invalid'
      render :action => 'new'
    end
  end

  # logout method. Destroy all ubiquo_user data and send ubiquo_user
  # to ubiquo_home (which commonly is login_required)
  def destroy
    self.current_ubiquo_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = t 'ubiquo.auth.logout'
    redirect_back_or_default(ubiquo_home_path)
  end
end
