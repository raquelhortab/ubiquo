module Ubiquo::ActivityInfosHelper
  def activity_info_filters_info(params)
    filters = []
    if Ubiquo::Config.context(:ubiquo_activity).get(:activities_controller_filter_enabled)
      filters << filter_info(:links, params,
             :field => :filter_controller,
             :name_field => :controller,
             :id_field => :controller,
             :collection => @controllers,
             :caption => t("ubiquo.activity_info.controller"))
    end
    if Ubiquo::Config.context(:ubiquo_activity).get(:activities_action_filter_enabled)
      filters << filter_info(:links, params,
             :field => :filter_action,
             :name_field => :action,
             :id_field => :action,
             :collection => @actions,
             :caption => t("ubiquo.activity_info.action"))      
    end
    if Ubiquo::Config.context(:ubiquo_activity).get(:activities_status_filter_enabled)
      filters << filter_info(:links, params,
             :field => :filter_status,
             :name_field => :status,
             :id_field => :status,
             :collection => @actions,
             :caption => t("ubiquo.activity_info.status"))    
    end
    build_filter_info(*filters)
  end

  def activity_info_filters(url_for_options = {})
    filters = []
    if Ubiquo::Config.context(:ubiquo_activity).get(:activities_controller_filter_enabled)    
      filters << render_filter(:links, url_for_options,
          :field => :filter_controller,
          :id_field => :controller,
          :name_field => :controller,
          :collection => @controllers,
          :caption => t("ubiquo.activity_info.controller"))
    end
    if Ubiquo::Config.context(:ubiquo_activity).get(:activities_action_filter_enabled)
      filters << render_filter(:links, url_for_options,
          :field => :filter_action,
          :id_field => :action,
          :name_field => :action,
          :collection => @actions,
          :caption => t("ubiquo.activity_info.action"))
    end
    if Ubiquo::Config.context(:ubiquo_activity).get(:activities_status_filter_enabled)
      filters << render_filter(:links, url_for_options,
          :field => :filter_status,
          :id_field => :status,
          :name_field => :status,
          :collection => @status,
          :caption => t("ubiquo.activity_info.status"))
    end        
    filters.join
  end

  def activity_info_list(collection, pages, options = {}, &block)
    concat render(:partial => "shared/ubiquo/lists/boxes", :locals => {
        :name => 'activity_info',
        :rows => collection.collect do |activity_info|
          {
            :id => activity_info.id,
            :content => capture(activity_info, &block),
            :actions => activity_info_actions(activity_info)
          }
        end,
        :pages => pages
      })
  end
    
  def activity_info_box(activity)
    custom_partial = File.join(RAILS_ROOT, "app", "views", activity.controller,
                               "_activity_#{activity.action}.html.erb")
    partial = if File.exist?(custom_partial)
      "#{activity.controller}/activity_#{activity.action}"
    else
      "shared/ubiquo/activity_infos/activity_#{activity.action}"
    end
    render :partial => partial, :locals => { :activity => activity }
  end
  
  private
    
  def activity_info_actions(activity_info, options = {})
    actions = []
    actions << link_to(t("ubiquo.remove"), [:ubiquo, activity_info], 
      :confirm => t("ubiquo.activity_info.index.confirm_removal"), :method => :delete
      )
    actions
  end
end
