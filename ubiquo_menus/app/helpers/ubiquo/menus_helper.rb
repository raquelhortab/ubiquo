module Ubiquo::MenusHelper
  include Ubiquo::MenuItemsHelper

  def menu_filters
    filters_for "Menu" do |f|
      f.text
    end
  end

  def menu_items_box(form)
    render :partial => "menu_items_box", :locals => {:form => form}
  end

  def link_to_add_nested_association(title, association)
    function_name = "add_nested_association"
    function      = "#{function_name}(this, \"#{association}\")"
    dom_id        = "add_#{association}_button"
    link_to_function(title ,function, :id => dom_id) +
      javascript_tag("Event.observe(window, 'load', function() { $('#{dom_id}').onclick(); });")
  end

  def link_to_remove_nested_association(title)
    function_name = "remove_nested_association"
    link_to_function(title, "#{function_name}(this)")
  end

  def menu_list(collection, pages, options = {})
    render(:partial => "shared/ubiquo/lists/standard", :locals => {
        :name => 'menu',
        :headers => options[:can_manage] ? [:name, :key] : [:name],
        :rows => collection.collect do |menu|
          {
            :id => menu.id,
            :columns => menu_column_values(menu, options),
            :actions => menu_actions(menu),
          }
        end,
        :pages => pages,
        :link_to_new => link_to_new(options)
      })
  end

  private

  def menu_column_values(menu, options = {})
    values = [menu.name]
    values << menu.key if options[:can_manage]
    values
  end

  def menu_actions(menu, options = {})
    uhook_menu_links(menu, options)
  end

  def link_to_new(options = {})
    allow_create = Ubiquo::Settings.context(:ubiquo_menus).get(:allow_create) rescue true
    allow_create ?  link_to(t("ubiquo.menu.index.new"), ubiquo.new_menu_path, :class => 'new') : ""
  end
end
