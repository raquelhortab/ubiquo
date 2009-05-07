class Ubiquo::UbiquoUsersController < UbiquoAreaController
  
  ubiquo_config_call(:user_access_control, {:context => :ubiquo_authentication})
  
  before_filter :load_roles
  
  # GET /ubiquo_users
  # GET /ubiquo_users.xml
  def index
    order_by = params[:order_by] || Ubiquo::Config.context(:ubiquo_authentication).get(:ubiquo_users_default_order_field)
    sort_order = params[:sort_order] || Ubiquo::Config.context(:ubiquo_authentication).get(:ubiquo_users_default_sort_order)
    per_page = Ubiquo::Config.context(:ubiquo_authentication).get(:ubiquo_users_elements_per_page)
    filters = {
      :filter_admin => (params[:filter_admin].blank? ? nil : params[:filter_admin].to_s=="1")
    }
    @ubiquo_users_pages, @ubiquo_users = UbiquoUser.paginate(:page => params[:page], :per_page => per_page) do
      UbiquoUser.filtered_search(filters, :order => order_by + " " + sort_order)
    end

    respond_to do |format|
      format.html { } # index.html.erb
      format.xml  {
        render :xml => @ubiquo_users
      }
    end
  end

  # GET /ubiquo_users/new
  # GET /ubiquo_users/new.xml
  def new
    @ubiquo_user = UbiquoUser.new(:is_active => true)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ubiquo_user }
    end
  end

  # GET /ubiquo_users/1/edit
  def edit
    @ubiquo_user = UbiquoUser.find(params[:id])
  end

  # POST /ubiquo_users
  # POST /ubiquo_users.xml
  def create
    @ubiquo_user = UbiquoUser.new(params[:ubiquo_user])

    respond_to do |format|
      if @ubiquo_user.save
        if params[:send_confirm_creation]
          UbiquoUsersNotifier.deliver_confirm_creation(
            @ubiquo_user, 
            params[:welcome_message], 
            request.host_with_port
            )
        end
        flash[:notice] = t("ubiquo.auth.user_created")
        format.html { redirect_to(ubiquo_ubiquo_users_path) }
        format.xml  { render :xml => @ubiquo_user, :status => :created, :location => @ubiquo_user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ubiquo_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ubiquo_users/1
  # PUT /ubiquo_users/1.xml
  def update
    @ubiquo_user = UbiquoUser.find(params[:id])
    %w{password password_confirmation}.each do |atr|
      params.delete(atr.to_sym) if params[atr.to_sym].blank?
    end

    respond_to do |format|
      if @ubiquo_user.update_attributes(params[:ubiquo_user])
        flash[:notice] = t("ubiquo.auth.user_edited")
        format.html { redirect_to(ubiquo_ubiquo_users_path) }
        format.xml  { head :ok }
      else
        flash[:error] = t("ubiquo.auth.user_edited_error")
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ubiquo_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ubiquo_users/1
  # DELETE /ubiquo_users/1.xml
  def destroy
    @ubiquo_user = UbiquoUser.find(params[:id])
    if @ubiquo_user.destroy
      flash[:notice] = t("ubiquo.auth.user_removed")
    else
      flash[:error] = t("ubiquo.auth.user_remove_error")
    end

    respond_to do |format|
      format.html { redirect_to(ubiquo_ubiquo_users_path) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def load_roles 
    @roles = Role.all
  end
end
