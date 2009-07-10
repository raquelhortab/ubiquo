class Ubiquo::ActivityInfosController < UbiquoAreaController
  ubiquo_config_call :activity_info_access_control, { :context => :ubiquo_activity }
  before_filter :load_controllers
  before_filter :load_actions
  before_filter :load_status
  
  # GET /activity_infos
  # GET /activity_infos.xml
  def index   
    order_by = params[:order_by] || Ubiquo::Config.context(:ubiquo_activity).get(:activities_default_order_field)
    sort_order = params[:sort_order] || Ubiquo::Config.context(:ubiquo_activity).get(:activities_default_sort_order)
    
    filters = {
      :controller => params[:filter_controller],
      :action => params[:filter_action],
      :status => params[:filter_status]
    }
    per_page = Ubiquo::Config.context(:ubiquo_activity).get(:activities_elements_per_page)
    @activity_infos_pages, @activity_infos = ActivityInfo.paginate(:page => params[:page]) do
      ActivityInfo.filtered_search filters, :order => "#{order_by} #{sort_order}"
    end
    
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
  
  def load_controllers
    @controllers = ActivityInfo.find(:all, 
                                     :select => :controller, 
                                     :group => :controller)
  end
  
  def load_actions
    @actions = ActivityInfo.find(:all,
                                 :select => :action,
                                 :group => :action)
  end
  
  def load_status
    @status = ActivityInfo.find(:all,
                                :select => :status,
                                :group => :status)
  end
end
