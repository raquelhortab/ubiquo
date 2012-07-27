class Ubiquo::PasswordsController < ApplicationController

  Nanoboy.load_extensions_for UbiquoController, self

  #shows the request pasword recovering form.
  def new
  end

  #resets the password of the user(finded by e-mail)
  def create
    @user = UbiquoUser.find_by_email(params[:email])
    if @user
      @user.reset_password!
      UbiquoUsersNotifier.forgot_password(@user, request.host_with_port).deliver
      flash[:notice] = t 'ubiquo.auth.password_reset'
      redirect_to ubiquo.new_session_path
    else
      flash[:error] = t 'ubiquo.auth.email_invalid'
      render :action => 'new'
    end
  end
end
