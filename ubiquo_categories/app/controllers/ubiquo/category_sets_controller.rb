class Ubiquo::CategorySetsController < UbiquoAreaController

  # GET /category_sets
  # GET /category_sets.xml
  def index   
    order_by = params[:order_by] || 'category_sets.id'
    sort_order = params[:sort_order] || 'desc'
    
    filters = {
      :text => params[:filter_text],
    }
    @category_sets_pages, @category_sets = CategorySet.paginate(:page => params[:page]) do
      # remove this find and add something like this:
      # CategorySet.filtered_search filters, :order => "#{order_by} #{sort_order}"
      CategorySet.filtered_search filters, :order => "#{order_by} #{sort_order}"
    end
    
    respond_to do |format|
      format.html # index.html.erb  
      format.xml  {
        render :xml => @category_sets
      }
    end
  end

  # GET /category_sets/1
  # GET /category_sets/1.xml
  def show
    @category_set = CategorySet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @category_set }
    end
  end


  # GET /category_sets/new
  # GET /category_sets/new.xml
  def new
    @category_set = CategorySet.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @category_set }
    end
  end

  # GET /category_sets/1/edit
  def edit
    @category_set = CategorySet.find(params[:id])
  end

  # POST /category_sets
  # POST /category_sets.xml
  def create
    @category_set = CategorySet.new(params[:category_set])

    respond_to do |format|
      if @category_set.save
        flash[:notice] = t("ubiquo.category_set.created")
        format.html { redirect_to(ubiquo_category_sets_url) }
        format.xml  { render :xml => @category_set, :status => :created, :location => @category_set }
      else
        flash[:error] = t("ubiquo.category_set.create_error")
        format.html { render :action => "new" }
        format.xml  { render :xml => @category_set.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /category_sets/1
  # PUT /category_sets/1.xml
  def update
    @category_set = CategorySet.find(params[:id])
    ok = @category_set.update_attributes(params[:category_set])

    respond_to do |format|
      if ok
        flash[:notice] = t("ubiquo.category_set.edited")
        format.html { redirect_to(ubiquo_category_sets_url) }
        format.xml  { head :ok }
      else
        flash[:error] = t("ubiquo.category_set.edit_error")
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category_set.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /category_sets/1
  # DELETE /category_sets/1.xml
  def destroy
    @category_set = CategorySet.find(params[:id])
    if @category_set.destroy
      flash[:notice] = t("ubiquo.category_set.destroyed")
    else
      flash[:error] = t("ubiquo.category_set.destroy_error")
    end
    respond_to do |format|
      format.html { redirect_to(ubiquo_category_sets_url) }
      format.xml  { head :ok }
    end
  end
end
