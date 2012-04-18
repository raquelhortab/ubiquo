module Ubiquo::MenuItemsHelper

  def content_for_item(item, item_id)
    render :partial => '/ubiquo/menu_items/list_item',
           :locals => { :menu_item => item, :item_id => item_id }
  end

  def build_items_header
    header = <<-eos
      <li class="header">
        <div class="handle-menuitem"></div>
        <div class="caption">#{t('ubiquo.menu.edit.menu_item.caption')}</div>
        <div class="actions">
          <div>#{t('ubiquo.menu.edit.menu_item.is_active')}</div>
          #{t('ubiquo.menu.edit.menu_item.actions')}
        </div>
      </li>
    eos
    header.html_safe
  end

  def menu_item_caption(menu_item)
    if menu_item.is_linkable? && menu_item.page.present?
      link_to menu_item.caption, url_for_page(menu_item.page)
    elsif menu_item.is_linkable?
      link_to menu_item.caption, menu_item.url
    else
      content_tag(:p, menu_item.caption)
    end
  end

  def build_item(item, parent_id)
    item_id = "#{parent_id}_#{item.id}"
    dom_class = "#{cycle('odd', 'even')}"
    dom_class += " item" unless item.uhook_skip_for_position_calculation?
    content_tag(:li, :id => item_id, :class => dom_class ) do
      inner = content_for_item(item, item_id)
      unless item.children.empty?
        item_as_parent_id = item_id + '_list'
        inner += render('/ubiquo/menu_items/index',
                        :items      => item.children,
                        :parent_id  => item_as_parent_id,
                        :menu_id    => item.menu_id)
      end
      inner
    end.html_safe
  end

  def css_list_parent_id parent_id
    "items_#{parent_id.to_i}"
  end

  def link_type_selector(form)
    output = form.select :link_type,
                options_for_select(form.object.class.translated_link_types, :selected => form.object.link_type),
                {},
                {:onchange => "syncMenuLinkableSettings()", :group => false, :class => 'menu_item_link_type'}

    js_code = <<-eos
        $$('.menu_item_link_type').each(function(e){e.observe("onchange", this.syncMenuLinkableSettings.bind(this))});
        syncMenuLinkableSettings();
      eos

    js_code = "document.observe('dom:loaded', function() {#{js_code}})" unless request.xhr?
    output += javascript_tag(js_code)
    output
  end

  def url_field(form)
    form.custom_block do
      form.text_field(:url, {
        :group => false,
        :label => '',
        :size => 20,
        :class => 'menu_item_url_link'
      })
    end
  end

  def page_selector(form)
    selector_options = {
      :hide_controls      => true,
      :autocomplete_style => "list",
      :group   => false
    }
    html_options = {
      #:class   => '',
      #:id      => '',
    }
    content_tag(:div, :id => "menu_item_page_link") do
      form.relation_selector(:page, selector_options, html_options)
    end
  end

  def caption_and_link_fields(form)
    render(:partial => '/ubiquo/menu_items/caption_and_link_form',
           :locals => { :form => form })
  end

  protected

  def menu_item_actions(menu_item, options = {})
    uhook_menu_item_links(menu_item)
  end

end
