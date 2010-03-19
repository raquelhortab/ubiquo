module Ubiquo::CategoriesHelper
  def category_filters_info(params)
    filters = []
    filters <<  filter_info(:string, params,
           :field => :filter_text,
           :caption => t('ubiquo.filters.text'))

    filters << filter_info(:string, params,
           :field => :filter_locale,
           :caption => Category.human_attribute_name("locale"))
    build_filter_info(*filters)
  end

  def category_filters(url_for_options = {})
    filters = []
    filters << render_filter(:string, url_for_options,
        :field => :filter_text,
        :caption => t('ubiquo.filters.text'))
        
    filters << render_filter(:links, url_for_options,
        :caption => Category.human_attribute_name("locale"),
        :field => :filter_locale,
        :collection => Locale.active,
        :id_field => :iso_code,
        :name_field => :native_name)
    filters.join
  end

  def category_list(collection, pages, options = {})
    render(:partial => "shared/ubiquo/lists/standard", :locals => {
        :name => 'category',
        :headers => [:name, :description],
        :rows => collection.collect do |category| 
          {
            :id => category.id, 
            :columns => [
              category.name,
              category.description,
            ],
            :actions => category_actions(options[:category_set], category)
          }
        end,
        :pages => pages,
        :link_to_new => link_to(t("ubiquo.category.index.new"),
                                new_ubiquo_category_set_category_path, :class => 'new')
      })
  end
    
  private
    
  def category_actions(category_set, category, options = {})
    actions = []
    if category.locale?(current_locale)
      actions << link_to(t("ubiquo.view"), [:ubiquo, category_set, category])
    end
   
    if category.locale?(current_locale)
      actions << link_to(t("ubiquo.edit"), [:edit, :ubiquo, category_set, category])
    end
  
    unless category.locale?(current_locale)
      actions << link_to(
        t("ubiquo.translate"), 
        new_ubiquo_category_set_category_path(
          :from => category.content_id
          )
        )
    end
  
    actions << link_to(t("ubiquo.remove"), 
      ubiquo_category_set_category_path(category_set, category, :destroy_content => true),
      :confirm => t("ubiquo.category.index.confirm_removal"), :method => :delete
      )
    
    if category.locale?(current_locale, :skip_any => true) && !category.translations.empty?
      actions << link_to(t("ubiquo.remove_translation"), [:ubiquo, category_set, category],
        :confirm => t("ubiquo.category.index.confirm_removal"), :method => :delete
        )
    end
    
    actions
  end
end
