class Ubiquo::MenuItemsController < UbiquoController
  ubiquo_config_call :menus_access_control, {:context => :ubiquo_menus}

  before_filter :load_menu

  # GET /menu/1/menu_items.xml
  # GET /menu/1/menu_items.json
  # GET /menu/1/menu_items.js
  def index

    @menu_items = uhook_find_menu_items.roots
    respond_to do |format|
      format.xml  {
        render :xml => @menu_items
      }
      format.js{
        render :json => Array(@menu_items).to_json(:only => [:caption, :id])
      }
    end
  end

  # GET /menu/1/menu_items/new
  # GET /menu/1menu_items/new.xml
  def new
    @menu_item = uhook_new_menu_item

    respond_to do |format|
      format.html # new.html.erb
      format.js  { render :action => :new, :layout => false }
    end
  end

  # GET /menu/1/menu_items/2/edit
  def edit
    @menu_item = MenuItem.find(params[:id])

    return if uhook_edit_menu_item(@menu_item) == false
    respond_to do |format|
      format.html # edit.html.erb
      format.js  { render :action => :edit, :layout => false }
    end
  end

  # POST /menu/1/menu_items
  # POST /menu/1/menu_items.xml
  def create
    @menu_item = uhook_create_menu_item

    respond_to do |format|
      if @menu_item.valid?
        flash[:notice] = t('ubiquo.menu_item.created')
        format.html { redirect_to(ubiquo.edit_menu_path(@menu_item.menu)) }
        format.xml  { render :xml => @menu_item, :status => :created, :location => @menu_item }
      else
        flash[:error] = t('ubiquo.menu_item.create_error')
        format.html { render :action => "new" }
        format.xml  { render :xml => @menu_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /menu/1/menu_items/2
  # PUT /menu/1/menu_items/2.xml
  def update
    @menu_item = MenuItem.find(params[:id])
    respond_to do |format|
      if uhook_update_menu_item(@menu_item)
        flash[:notice] = t('ubiquo.menu_item.updated')
        format.html { redirect_to(ubiquo.edit_menu_path(@menu_item.menu)) }
        format.xml  { head :ok }
      else
        flash[:error] = t('ubiquo.menu_item.update_error')
        format.html { render :action => "edit" }
        format.xml  { render :xml => @menu_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /menu/1/menu_items/2
  # DELETE /menu/1/menu_items/2.xml
  def destroy
    @menu_item = MenuItem.find(params[:id])
    @menu = @menu_item.menu if @menu_item.present?
    if uhook_destroy_menu_item(@menu_item)
      flash[:notice] = t('ubiquo.menu_item.removed')
    else
      flash[:error] = t('ubiquo.menu_item.remove_error')
    end

    respond_to do |format|
      format.html { redirect_to(ubiquo.edit_menu_path(@menu_item.menu)) }
      format.xml  { head :ok }
    end
  end

  # PUT /ubiquo/menu/1/menu_items/update_positions
  #
  # Called when the menu items has been re-ordered, updates
  # immediately the records to reflect the new order
  def update_positions
    @menu.update_positions!(params[params[:column]].select(&:present?))
    head :ok
  end

  # PUT /ubiquo/menu/1/menu_items/2/update_positions
  #
  # Called when the a menu_item is_active field is toggled
  def toggle_active
    @menu_item = MenuItem.find(params[:id])
    ok = @menu_item.update_attributes(:is_active => !@menu_item.is_active)
    if ok
      flash[:notice] = t('ubiquo.menu_item.updated')
    else
      flash[:error] = t('ubiquo.menu_item.update_error')
    end
    respond_to do |format|
      format.html { redirect_to(ubiquo.edit_menu_path(@menu_item.menu)) }
      format.xml  { head :ok }
    end
  end


  protected

  def load_menu
    @menu = Menu.find(params[:menu_id])
  end
end
