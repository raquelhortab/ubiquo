class Ubiquo::RolesController < UbiquoController

  ubiquo_config_call :role_access_control, {:context => :ubiquo_access_control}

  before_filter :load_permissions

  # GET /roles
  # GET /roles.xml
  def index
    params[:order_by] = params[:order_by] || Ubiquo::Settings.context(:ubiquo_access_control).get(:roles_default_order_field)
    params[:sort_order] = params[:sort_order] || Ubiquo::Settings.context(:ubiquo_access_control).get(:roles_default_sort_order)
    per_page = Ubiquo::Settings.context(:ubiquo_access_control).get(:roles_elements_per_page)
    @roles_pages, @roles = Role.paginated_filtered_search(params.merge(:per_page => per_page))

    respond_to do |format|
      format.html {} # index.html.erb
      format.xml  {
        render :xml => @roles
      }
    end
  end

  # GET /roles/new
  # GET /roles/new.xml
  def new
    @role = Role.new()
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/1/edit
  def edit
    @role = Role.find(params[:id])
  end

  # POST /roles
  # POST /roles.xml
  def create
    @role = Role.new(params[:role])
    respond_to do |format|
      if @role.save
        [params[:permissions]].flatten.each do |permission|
          if perm = Permission.gfind(permission)
            @role.permissions << perm
          end
        end
        return if check_redirects(@role)
        flash[:notice] = t('ubiquo.auth.role_created')
        format.html { redirect_to(ubiquo.roles_path) }
        format.xml  { render :xml => @role, :status => :created, :location => @role }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /roles/1
  # PUT /roles/1.xml
  def update
    @role = Role.find(params[:id])
    @role.role_permissions.delete_all
    [params[:permissions]].flatten.each do |permission|
      if perm = Permission.gfind(permission)
        @role.permissions << perm
      end
    end
    respond_to do |format|
      if @role.update_attributes(params[:role])
        return if check_redirects(@role)
        flash[:notice] = t('ubiquo.auth.role_edited')
        format.html { redirect_to(ubiquo.roles_path) }
        format.xml  { head :ok }
      else
        flash[:error] = t('ubiquo.auth.role_edit_error')
        format.html { render :action => "edit" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    @role = Role.find(params[:id])
    if @role.destroy
      flash[:notice] = t('ubiquo.auth.role_removed')
    else
      flash[:error] = t('ubiquo.auth.role_remove_error')
    end

    respond_to do |format|
      format.html { redirect_to(ubiquo.roles_path) }
      format.xml  { head :ok }
    end
  end

  private

  def load_permissions
    @permissions = Permission.all
  end
end
