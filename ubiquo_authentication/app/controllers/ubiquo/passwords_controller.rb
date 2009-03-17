class Ubiquo::PasswordsController < ApplicationController
  
  def new
  end

  def create
    @user = UbiquoUser.find_by_email(params[:email])
    if(@user)
      @user.reset_password!
      UbiquoUsersNotifier.deliver_forgot_password(@user, request.host_with_port)
      
      flash[:notice] = t 'ubiquo.auth.password_reset'
      redirect_to new_ubiquo_session_path
    else
      flash[:error] = t 'ubiquo.auth.email_invalid'
      render :action => 'new'
    end
  end
end
