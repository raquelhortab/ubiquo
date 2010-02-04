module Ubiquo::ActivityInfosHelper
  def activity_info_filters_info(params)
    filters = []
    if Ubiquo::Config.context(:ubiquo_activity).get(:activities_date_filter_enabled)
      filters << filter_info(:date, params,
             :caption => t("ubiquo.activity_info.date"),
             :field => [:filter_date_start, :filter_date_end])
    end    
    if Ubiquo::Config.context(:ubiquo_activity).get(:activities_user_filter_enabled)
      filters << filter_info(:links_or_select, params,
             :field => :filter_user,
             :name_field => :full_name,
             :id_field => :ubiquo_user_id,
             :collection => @users,
             :caption => ActivityInfo.human_attribute_name(:user))
    end
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
             :collection => @statuses,
             :caption => t("ubiquo.activity_info.status"))    
    end
    build_filter_info(*filters)
  end

  def activity_info_filters(url_for_options = {})
    filters = []
    if Ubiquo::Config.context(:ubiquo_activity).get(:activities_date_filter_enabled)
      filters << render_filter(:date, url_for_options,
          :caption => t("ubiquo.activity_info.date"),
          :field => [:filter_date_start, :filter_date_end])
    end
    if Ubiquo::Config.context(:ubiquo_activity).get(:activities_user_filter_enabled)
      filters << render_filter(:links_or_select, url_for_options,
          :field => :filter_user,
          :id_field => :ubiquo_user_id,
          :name_field => :full_name,
          :collection => @users,
          :caption => ActivityInfo.human_attribute_name(:user))
    end
    if Ubiquo::Config.context(:ubiquo_activity).get(:activities_controller_filter_enabled)    
      filters << render_filter(:links, url_for_options,
          :field => :filter_controller,
          :id_field => :key,
          :name_field => :name,
          :collection => @controllers,
          :caption => t("ubiquo.activity_info.controller"))
    end
    if Ubiquo::Config.context(:ubiquo_activity).get(:activities_action_filter_enabled)
      filters << render_filter(:links, url_for_options,
          :field => :filter_action,
          :id_field => :key,
          :name_field => :name,
          :collection => @actions,
          :caption => t("ubiquo.activity_info.action"))
    end
    if Ubiquo::Config.context(:ubiquo_activity).get(:activities_status_filter_enabled)
      filters << render_filter(:links, url_for_options,
          :field => :filter_status,
          :id_field => :key,
          :name_field => :name,
          :collection => @statuses,
          :caption => t("ubiquo.activity_info.status"))
    end        
    filters.join
  end

  def activity_info_list(collection, pages, options = {}, &block)
    list_partial = Ubiquo::Config.context(:ubiquo_activity).get(:info_list_partial)
    concat render(:partial => "shared/ubiquo/lists/#{list_partial}", :locals => {
        :name => 'activity_info',
        :headers => [
          ActivityInfo.human_attribute_name(:user),
          :controller,
          :action,
          :status,
          :created_at
        ],
        :rows => collection.collect do |activity_info|
          {
            :id => activity_info.id,
            :columns => [
              activity_info.ubiquo_user.name,
              t("ubiquo.#{activity_info.controller.gsub('ubiquo/', '').singularize}.title"),
              t("ubiquo.activity_info.actions.#{activity_info.action}"),
              t("ubiquo.activity_info.statuses.#{activity_info.status}"),
              l(activity_info.created_at)
            ],
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
