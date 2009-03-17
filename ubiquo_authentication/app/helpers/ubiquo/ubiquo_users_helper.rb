module Ubiquo::UbiquoUsersHelper
  def ubiquo_users_filters_info(params)
    admin_filter = if Ubiquo::Config.context(:ubiquo_authentication).get(:ubiquo_users_admin_filter_enabled)
      filter_info(:links, params,
        :caption => t('ubiquo.auth.user_type'),
        :boolean => true,    
        :caption_true => t('ubiquo.auth.user_admin'),
        :caption_false => t('ubiquo.auth.user_non_admin'),
        :field => :filter_admin)
    else
      nil
    end
    build_filter_info(admin_filter)
  end

  def ubiquo_users_filters(url_for_options = {})
    admin_filter = if Ubiquo::Config.context(:ubiquo_authentication).get(:ubiquo_users_admin_filter_enabled)
      render_filter(:links, url_for_options,
        :caption => t('ubiquo.auth.user_type'),
        :boolean => true,    
        :caption_true => t('ubiquo.auth.user_admin'),
        :caption_false => t('ubiquo.auth.user_non_admin'),
        :field => :filter_admin)
    else
      ""
    end
    admin_filter
  end

end
