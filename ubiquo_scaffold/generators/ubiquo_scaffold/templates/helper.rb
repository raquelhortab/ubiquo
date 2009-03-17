module Ubiquo::<%= controller_class_name %>Helper
  def <%= singular_name %>_filters_info(params)
    string_filter = filter_info(:string, params,
           :field => :filter_text,
           :caption => t('ubiquo.text'))

    <%- if has_published_at -%>
    publish_filter = filter_info(:date, params,
        :caption => <%= model_name %>.human_attribute_name("published_at"),
        :field => [:filter_publish_start, :filter_publish_end])
    
    build_filter_info(string_filter, publish_filter)
    <%- else -%>
    build_filter_info(string_filter)
    <%- end -%>
  end

  def <%= singular_name %>_filters(url_for_options = {})
    string_filter = render_filter(:string, url_for_options,
        :field => :filter_text,
        :caption => t('ubiquo.text'))
        
    <%- if has_published_at -%>
    publish_filter = render_filter(:date, url_for_options,
        :caption => <%= model_name %>.human_attribute_name("published_at"),
        :field => [:filter_publish_start, :filter_publish_end])
        
    string_filter + publish_filter
    <%- else -%>
    string_filter
    <%- end -%>
  end
end
