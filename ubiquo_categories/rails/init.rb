require 'ubiquo_categories'

Ubiquo::Plugin.register(:ubiquo_categories, directory, config) do |config|
  config.add :category_sets_per_page
  config.add_inheritance :category_sets_per_page, :elements_per_page

  config.add :categories_per_page
  config.add_inheritance :categories_per_page, :elements_per_page

  config.add :categories_access_control, lambda{
    access_control :DEFAULT => 'categories_management'
  }
  config.add :categories_permit, lambda{
   permit?('categories_management')
  }
end
