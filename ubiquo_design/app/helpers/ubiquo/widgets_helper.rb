module Ubiquo::WidgetsHelper
  def widget_form(page, widget, &block)
    widget_form = %{
      <div class="content-widget">
        %s
      </div>
    } % [widget_remote_form_for(widget, page, &block)]
    
    raw widget_form
  end
  
  def widget_submit
    submit = %{
      <p class="form_buttons">
        <input type="submit" class="button" value="%s" />
      </p>
    } % [t('ubiquo.design.save')]

    raw submit
  end

  def widget_header(widget)
    header =  %{
      <h3>%s</h3>
      <a href="#" class="lightwindow_action close" rel="deactivate">%s</a>
      <div id="error_messages"></div>
    } % [(t('ubiquo.design.editing_widget', :name => widget.name)), t('ubiquo.design.close_widget')]

    raw header
  end

  def li_widget_attributes(widget, page)
    attributes = {}
    classes = ["widget"]
    classes << "error" unless widget.valid?
    classes << "inherited" unless page.blocks.include?(widget.block)
    attributes[:class] = classes.join(' ')
    attributes[:id] = "widget_#{widget.id}"

    unless widget.valid?
      attributes[:alt] = "#{t("ubiquo.design.widget_error")}"
      attributes[:title] = "#{t("ubiquo.design.widget_error")}"
    end
    attributes
  end
  
  def widget_remote_form_for(widget, page, &block)
    remote_form_for(
      :widget,
      widget,
      :url => ubiquo.page_widget_path(:page_id => page.id,
                                      :id      => widget.id,
                                      :format  => :js),
      :before => 'killeditor()',
      :html   => { :method => :put,
                   :name   => "widget_edit_form",
                   :id     => "widget_form", },
       &block
    )
  end
  
end
