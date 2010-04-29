module Ubiquo::CategoriesHelper
  def category_filters_info(params)
    filters = []
    filters <<  filter_info(:string, params,
           :field => :filter_text,
           :caption => t('ubiquo.filters.text'))

    filters += uhook_category_filters_info
    build_filter_info(*filters)
  end

  def category_filters(url_for_options = {})
    filters = []
    filters << render_filter(:string, url_for_options,
        :field => :filter_text,
        :caption => t('ubiquo.filters.text'))
        
    filters << uhook_category_filters(url_for_options)
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
            :actions => uhook_category_index_actions(options[:category_set], category)
          }
        end,
        :pages => pages,
        :hide_actions => !options[:category_set].is_editable?,
        :link_to_new => (
          link_to(
            t("ubiquo.category.index.new"),
            new_ubiquo_category_set_category_path, :class => 'new'
          ) if options[:category_set].is_editable?)
      })
  end

end
