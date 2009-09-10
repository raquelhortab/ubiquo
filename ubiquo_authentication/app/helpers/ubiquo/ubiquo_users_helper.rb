module Ubiquo::UbiquoUsersHelper
  # returns the filter info for the active filters of ubiquo_users list
  def ubiquo_users_filters_info(params)
    filters = []
    if Ubiquo::Config.context(:ubiquo_authentication).get(:ubiquo_users_string_filter_enabled)
      filters << filter_info(:string, params,
        :field => :filter_text,
        :caption => t('ubiquo.text'))
    end
    if Ubiquo::Config.context(:ubiquo_authentication).get(:ubiquo_users_admin_filter_enabled)
      filters << filter_info(:links, params,
        :caption => t('ubiquo.auth.user_type'),
        :boolean => true,    
        :caption_true => t('ubiquo.auth.user_admin'),
        :caption_false => t('ubiquo.auth.user_non_admin'),
        :field => :filter_admin)
    end
    
    build_filter_info(*filters)
  end

  #return the enabled filters for ubiquo_users lists
  def ubiquo_users_filters(url_for_options = {})
    filters = []
    if Ubiquo::Config.context(:ubiquo_authentication).get(:ubiquo_users_string_filter_enabled)
      filters << render_filter(:string, url_for_options,
        :field => :filter_text,
        :caption => t('ubiquo.text'))
    end
    if Ubiquo::Config.context(:ubiquo_authentication).get(:ubiquo_users_admin_filter_enabled)
      filters << render_filter(:links, url_for_options,
        :caption => t('ubiquo.auth.user_type'),
        :boolean => true,    
        :caption_true => t('ubiquo.auth.user_admin'),
        :caption_false => t('ubiquo.auth.user_non_admin'),
        :field => :filter_admin)
    end
    filters.join
  end
  
  #renders the ubiquo_user list
  def ubiquo_user_list(collection, pages, options = {}, &block)
    concat render(:partial => "shared/ubiquo/lists/boxes", :locals => {
        :name => 'ubiquo_user',
        :rows => collection.collect do |ubiquo_user| 
          {
            :id => ubiquo_user.id, 
            :content => capture(ubiquo_user, &block),
            :actions => ubiquo_user_actions(ubiquo_user)
          }
        end,
        :pages => pages,
        :link_to_new => link_to(t("ubiquo.auth.new_user"),
                        new_ubiquo_ubiquo_user_path, :class => 'new')
      })
  end
    
  private
  
  #return the actios related to an ubiquo_user
  def ubiquo_user_actions(ubiquo_user, options = {})
    actions = []
    actions << link_to(t("ubiquo.edit"), [:edit, :ubiquo, ubiquo_user], :class => "edit")
    actions << link_to(t("ubiquo.remove"), [:ubiquo, ubiquo_user], 
      :confirm => t("ubiquo.auth.confirm_user_removal"), :method => :delete, :class => "delete")
    actions
  end

end
