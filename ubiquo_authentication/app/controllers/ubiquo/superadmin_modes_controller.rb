class Ubiquo::SuperadminModesController < UbiquoAreaController

  def create
    session[:superadmin_mode] = current_ubiquo_user.is_superadmin?
    redirect_to_home
  end
  
  def destroy
    session[:superadmin_mode] = false
    redirect_to_home
  end
  
  private
  
  def redirect_to_home
    redirect_to session[:superadmin_mode] ? ubiquo_superadmin_home_path : ubiquo_home_path
  end
end
