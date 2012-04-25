class Ubiquo::MenusController < UbiquoController
  ubiquo_config_call :menus_access_control, {:context => :ubiquo_menus}

  before_filter :can_manage?

  helper "ubiquo/menu_items"

  # TODO FIXME Waiting to implement json index for all controllers
  # GET /menus
  # GET /menus.xml
  # GET /menus.json
  # GET /menus.js
  def index
    @menus_pages, @menus = uhook_find_menus

    respond_to do |format|
      format.html # index.html.erb
      format.xml  {
        render :xml => @menus
      }
      format.json  {
        render :json => @menus.to_json(:only => [:name, :id])
      }
      format.js{
        render :json => @menus.to_json(:only => [:name, :id])
      }
    end
  end

  # GET /menus/new
  # GET /menus/new.xml
  def new
    @menu = uhook_new_menu

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @menu }
    end
  end

  # GET /menus/1/edit
  def edit
    @menu = uhook_load_menu
    @menu.menu_items

    return if uhook_edit_menu(@menu) == false
  end

  # POST /menus
  # POST /menus.xml
  def create
    @menu = uhook_create_menu

    respond_to do |format|
      if @menu.valid?
        flash[:notice] = t("ubiquo.menu.created")
        return if check_redirects(@menu)
        format.html { redirect_to(ubiquo.edit_menu_path(@menu)) }
        format.xml  { render :xml => @menu, :status => :created, :location => @menu }
      else
        flash[:error] = t("ubiquo.menu.create_error")
        format.html { render :action => "new" }
        format.xml  { render :xml => @menu.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /menus/1
  # PUT /menus/1.xml
  def update
    @menu = Menu.find(params[:id])

    respond_to do |format|
      if uhook_update_menu(@menu)
        flash[:notice] = t("ubiquo.menu.edited")
        return if check_redirects(@menu)
        format.html { redirect_to(ubiquo.menus_url) }
        format.xml  { head :ok }
      else
        flash[:error] = t("ubiquo.menu.edit_error")
        format.html { render :action => "edit" }
        format.xml  { render :xml => @menu.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /menus/1
  # DELETE /menus/1.xml
  def destroy
    @menu = Menu.find(params[:id])
    if uhook_destroy_menu(@menu)
      flash[:notice] = t("ubiquo.menu.destroyed")
    else
      flash[:error] = t("ubiquo.menu.destroy_error")
    end
    respond_to do |format|
      format.html { redirect_to(ubiquo.menus_url) }
      format.xml  { head :ok }
    end
  end

  def nested_fields
    @menu = Menu.find_by_id(params[:id]) || Menu.new
    association = params[:association].to_sym
    nested_object = @menu.class.reflections[association].klass.new
    respond_to do |format|
      format.js{
        render(:partial => 'nested_fields',
               :locals  => { :object => @menu,
                             :nested_object => nested_object,
                             :association => association } )
      }
    end
  end

  private

  def check_redirects object
    if params[:save_and_continue] && !object.errors.present?
      redirect_to :action => 'edit', :id => object.id
      return true
    end
    if params[:save_and_new] && !object.errors.present?
      redirect_to :action => 'new', :params => nil
      return true
    end
    return false
  end

  def can_manage?
    global = Ubiquo::Settings.context(:ubiquo_menus).get(:administrable_menus)
    @can_manage = global && permit?('menus_keys_management')
  end
end
