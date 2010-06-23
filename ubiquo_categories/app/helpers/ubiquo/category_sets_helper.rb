module Ubiquo::CategorySetsHelper
  def category_set_filters_info(params)
    filters = []
    filters <<  filter_info(:string, params,
           :field => :filter_text,
           :caption => t('ubiquo.filters.text'))

    build_filter_info(*filters)
  end

  def category_set_filters(url_for_options = {})
    filters = []
    filters << render_filter(:string, url_for_options,
        :field => :filter_text,
        :caption => t('ubiquo.filters.text'))
        
    filters.join
  end

  def category_set_list(collection, pages, options = {})
    render(:partial => "shared/ubiquo/lists/standard", :locals => {
        :name => 'category_set',
        :headers => options[:can_manage] ? [:name, :key] : [:name],
        :rows => collection.collect do |category_set| 
          {
            :id => category_set.id, 
            :columns => category_set_column_values(category_set, options),
            :actions => category_set_actions(category_set, options)
          }
        end,
        :pages => pages,
        :link_to_new => (
          link_to(
            t("ubiquo.category_set.index.new"),
            new_ubiquo_category_set_path, :class => 'new'
          ) if options[:can_manage])
      })
  end
    
  private
    
  def category_set_actions(category_set, options = {})
    actions = []
    actions << link_to(t("ubiquo.category_set.see_categories"), [:ubiquo, category_set, :categories])
    if options[:can_manage] && category_set.is_editable?
      actions << link_to(t("ubiquo.edit"), [:edit, :ubiquo, category_set])
      actions << link_to(t("ubiquo.remove"), [:ubiquo, category_set], 
        :confirm => t("ubiquo.category_set.index.confirm_removal"), :method => :delete)
    end
    actions
  end

  def category_set_column_values(category_set, options = {})
    values = [category_set.name]
    values << category_set.key if options[:can_manage]
    values
  end
end
