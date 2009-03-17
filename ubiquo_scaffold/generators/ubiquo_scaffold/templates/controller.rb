class Ubiquo::<%= controller_class_name %>Controller < UbiquoAreaController
  # GET /<%= table_name %>
  # GET /<%= table_name %>.xml
  def index
    respond_to do |format|
      format.html {
        order_by = params[:order_by] || '<%=plural_name%>.id'
        sort_order = params[:sort_order] || 'desc'
        
        filters = {
          :text => params[:filter_text],
          <%- if has_published_at -%>
          :publish_start => parse_date(params[:filter_publish_start]),
          :publish_end => parse_date(params[:filter_publish_end], :time_offset => 1.day),
          <%- end -%>
        }
        @<%= table_name %>_pages, @<%= table_name %> = <%= class_name %>.paginate(:page => params[:page]) do
          # remove this find and add something like this:
          # <%= class_name %>.filtered_search filters, :order => "#{order_by} #{sort_order}"
          <%= class_name %>.filtered_search filters, :order => "#{order_by} #{sort_order}"
        end
      } # index.html.erb  
      format.xml  {
        @<%= table_name %> = <%= class_name %>.find(:all)
        render :xml => @<%= table_name %>
      }
    end
  end

  # GET /<%= table_name %>/new
  # GET /<%= table_name %>/new.xml
  def new
    @<%= file_name %> = <%= class_name %>.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # GET /<%= table_name %>/1/edit
  def edit
    @<%= file_name %> = <%= class_name %>.find(params[:id])
  end

  # POST /<%= table_name %>
  # POST /<%= table_name %>.xml
  def create
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])

    respond_to do |format|
      if @<%= file_name %>.save
        flash[:notice] = t("ubiquo.<%= singular_name %>.created")
        format.html { redirect_to(ubiquo_<%= table_name %>_path) }
        format.xml  { render :xml => @<%= file_name %>, :status => :created, :location => @<%= file_name %> }
      else
        flash[:error] = t("ubiquo.<%= singular_name %>.create_error")
        format.html { render :action => "new" }
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /<%= table_name %>/1
  # PUT /<%= table_name %>/1.xml
  def update
    @<%= file_name %> = <%= class_name %>.find(params[:id])

    respond_to do |format|
      if @<%= file_name %>.update_attributes(params[:<%= file_name %>])
        flash[:notice] = t("ubiquo.<%= singular_name %>.edited")
        format.html { redirect_to(ubiquo_<%= table_name %>_path) }
        format.xml  { head :ok }
      else
        flash[:error] = t("ubiquo.<%= singular_name %>.edit_error")
        format.html { render :action => "edit" }
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /<%= table_name %>/1
  # DELETE /<%= table_name %>/1.xml
  def destroy
    @<%= file_name %> = <%= class_name %>.find(params[:id])
    if @<%= file_name %>.destroy
      flash[:notice] = t("ubiquo.<%= singular_name %>.destroyed")
    else
      flash[:error] = t("ubiquo.<%= singular_name %>.destroy_error")
    end

    respond_to do |format|
      format.html { redirect_to(ubiquo_<%= table_name %>_path) }
      format.xml  { head :ok }
    end
  end
end
