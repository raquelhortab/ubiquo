class Ubiquo::CategoriesController < UbiquoAreaController

  before_filter :load_category_set

  # GET /categories
  # GET /categories.xml
  def index
    order_by = params[:order_by] || 'categories.id'
    sort_order = params[:sort_order] || 'desc'
    
    filters = {
      :text => params[:filter_text],
      :locale => params[:filter_locale],
    }
    @categories_pages, @categories = Category.paginate(:page => params[:page]) do
      # remove this find and add something like this:
      # Category.filtered_search filters, :order => "#{order_by} #{sort_order}"
      Category.locale(current_locale, :ALL).filtered_search filters, :order => "#{order_by} #{sort_order}"
    end
    
    respond_to do |format|
      format.html # index.html.erb  
      format.xml  {
        render :xml => @categories
      }
    end
  end

  # GET /categories/1
  # GET /categories/1.xml
  def show
    @category = Category.find(params[:id])

    unless @category.locale?(current_locale)
      redirect_to(ubiquo_categories_url)
      return
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @category }
    end
  end


  # GET /categories/new
  # GET /categories/new.xml
  def new
    @category = Category.translate(params[:from], current_locale, :copy_all => true)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @category }
    end
  end

  # GET /categories/1/edit
  def edit
    @category = Category.find(params[:id])
    unless @category.locale?(current_locale)
      redirect_to(ubiquo_categories_url)
      return
    end
  end

  # POST /categories
  # POST /categories.xml
  def create
    @category = Category.new(params[:category])
    @category.locale = current_locale

    respond_to do |format|
      if @category.save
        flash[:notice] = t("ubiquo.category.created")
        format.html { redirect_to(ubiquo_category_set_categories_url) }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        flash[:error] = t("ubiquo.category.create_error")
        format.html { render :action => "new" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.xml
  def update
    @category = Category.find(params[:id])
    ok = @category.update_attributes(params[:category])

    respond_to do |format|
      if ok
        flash[:notice] = t("ubiquo.category.edited")
        format.html { redirect_to(ubiquo_category_set_categories_url) }
        format.xml  { head :ok }
      else
        flash[:error] = t("ubiquo.category.edit_error")
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.xml
  def destroy
    @category = Category.find(params[:id])
    destroyed = false
    if params[:destroy_content]
      destroyed = @category.destroy_content
    else
      destroyed = @category.destroy
    end    
    if destroyed
      flash[:notice] = t("ubiquo.category.destroyed")
    else
      flash[:error] = t("ubiquo.category.destroy_error")
    end
    respond_to do |format|
      format.html { redirect_to(ubiquo_category_set_categories_url) }
      format.xml  { head :ok }
    end
  end

  protected

  def load_category_set
    @category_set = CategorySet.find(params[:category_set_id])
  end
end
