class Ubiquo::UbiquoUserProfilesController < UbiquoAreaController
  def edit
    @ubiquo_user = current_ubiquo_user
  end
  
  def update
    @ubiquo_user = current_ubiquo_user
    %w{password password_confirmation}.each do |atr|
      params.delete(atr.to_sym) if params[atr.to_sym].blank?
    end
    

    respond_to do |format|
      if @ubiquo_user.update_attributes(params[:ubiquo_user])
        flash[:notice] = t("ubiquo.auth.user_edited")
        format.html { redirect_to(edit_ubiquo_ubiquo_user_profile_path) }
        format.xml  { head :ok }
      else
        flash[:error] = t("ubiquo.auth.user_edited_error")
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ubiquo_user.errors, :status => :unprocessable_entity }
      end
    end
  end
end
