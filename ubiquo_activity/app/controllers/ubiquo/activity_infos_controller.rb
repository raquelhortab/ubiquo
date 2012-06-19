class Ubiquo::ActivityInfosController < UbiquoController
  ubiquo_config_call :activity_info_access_control, { :context => :ubiquo_activity }
  before_filter :load_vars_for_filters

  # GET /activity_infos
  # GET /activity_infos.xml
  def index
    order_by = params[:order_by] || Ubiquo::Config.context(:ubiquo_activity).get(:activities_default_order_field)
    sort_order = params[:sort_order] || Ubiquo::Config.context(:ubiquo_activity).get(:activities_default_sort_order)

    per_page = Ubiquo::Config.context(:ubiquo_activity).get(:activities_elements_per_page)
    @activity_infos_pages, @activity_infos = ActivityInfo.paginated_filtered_search(params.merge(:per_page => per_page))
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  {
        render :xml => @activity_infos
      }
    end
  end

  # GET /activity_infos/1
  # GET /activity_infos/1.xml
  def show
    @activity_info = ActivityInfo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @activity_info }
    end

  end

  # DELETE /activity_infos/1
  # DELETE /activity_infos/1.xml
  def destroy
    @activity_info = ActivityInfo.find(params[:id])

    destroyed = false
    if params[:destroy_content]
      destroyed = @activity_info.destroy_content
    else
      destroyed = @activity_info.destroy
    end
    if destroyed
      store_activity :successful
      flash[:notice] = t("ubiquo.activity_info.destroyed")
    else
      store_activity :error
      flash[:error] = t("ubiquo.activity_info.destroy_error")
    end

    respond_to do |format|
      format.html { redirect_to(ubiquo_activity_infos_path) }
      format.xml  { head :ok }
    end
  end

  private

  def load_vars_for_filters
    ["controller", "action", "status"].each do |var_name|
      collection = ActivityInfo.find(:all,
                                     :select => var_name.to_sym,
                                     :group => var_name.to_sym)
      translated_collection = collection.collect do |elem|
        name = if var_name == "controller"
          t("ubiquo.#{elem.send(var_name).gsub('ubiquo/', '').singularize}.title")
        else
          t("ubiquo.activity_info.#{var_name.pluralize}.#{elem.send(var_name)}")
        end
        OpenStruct.new(:key => elem.send(var_name),
                       :name => name)
      end
      self.instance_variable_set "@#{var_name.pluralize}", translated_collection
    end

    @users = ActivityInfo.users_info.all
  end
end
