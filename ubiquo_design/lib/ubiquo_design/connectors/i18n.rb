module UbiquoDesign
  module Connectors
    class I18n < Standard

      def self.load!
        super
        ::Widget.send(:include, self::Widget)
        # TODO include i18n goodies in ::PublicController, not ::PagesController
        #::PagesController.send(:include, UbiquoI18n::Extensions::LocaleChanger)
        #::PagesController.send(:helper, UbiquoI18n::Extensions::Helpers)
      end

      # Validates the ubiquo_i18n-related dependencies
      def self.validate_requirements
        validate_i18n_requirements(::Widget)
      end

      def self.unload!
        # TODO create generic methods for these cleanups
        ([::Widget] + ::Widget.send(:subclasses)).each do |klass|
          klass.instance_variable_set :@translatable, nil
          klass.reset_column_information
          klass.clear_locale_uniqueness_per_entity_validation if klass.respond_to?(:clear_locale_uniqueness_per_entity_validation)
        end
        ::Widget.send :alias_method, :block, :block_without_shared_translations
        # Unfortunately there's no neat way to clear the helpers mess
        %w{Widgets}.each do |controller_name|
          ::Ubiquo.send(:remove_const, "#{controller_name}Controller")
          load "ubiquo/#{controller_name.tableize}_controller.rb"
        end
      end

      module Widget
        def self.included(klass)
          klass.send :translatable, :options
          klass.share_translations_for :block
        end
      end

      module Page

        def self.included(klass)
          klass.send(:include, self::InstanceMethods)
          I18n.register_uhooks klass, InstanceMethods
        end

        module InstanceMethods
          include Standard::Page::InstanceMethods

          def uhook_add_widget(widget, &block)
            widget.without_current_locale do
              yield
            end
          end

          def uhook_publish_block_widgets(block, new_block)
            # we need to relate the cloned widgets between them,
            # same as they are in the draft page, using the content_id
            mapped_content_ids = {}
            block.widgets.each do |widget|
              next_content_id = mapped_content_ids[widget.content_id]

              new_widget = widget.dup
              new_widget.block = new_block
              new_widget.content_id = next_content_id
              new_widget.save!(:validate => false)

              mapped_content_ids[widget.content_id] = new_widget.content_id

              yield widget, new_widget
              new_widget.without_page_expiration do
                new_widget.without_current_locale do
                  new_widget.save! # must validate now
                end
              end
            end
          end

          def uhook_static_section_widget(locale = nil)
            locale ||= Locale.current
            block_type = Ubiquo::Config.context(:ubiquo_design).get(:block_type_for_static_section_widget)
            block = self.blocks.select { |b| b.block_type == block_type }.first
            if block
              ::Widget.locale(locale).first(:conditions => {
                :type => "StaticSection", :block_id => block.id
              })
            end
          end
        end
      end

      module UbiquoDesignsHelper
        def self.included(klass)
          klass.send(:helper, Helper)
        end
        module Helper
          def uhook_link_to_edit_widget(widget)
            if widget.locale == current_locale
              link_to t('ubiquo.design.widget_edit'), ubiquo.page_widget_path(@page, widget), :class => "edit lightwindow", :type => "page", :params => "lightwindow_form=widget_edit_form,lightwindow_width=610", :id => "edit_widget_#{widget.id}", :alt =>t('ubiquo.design.widget_edit'), :title=>t('ubiquo.design.widget_edit')
            else
              link_to t('ubiquo.design.widget_translate'), ubiquo.page_widget_path(@page, widget), :class => "edit lightwindow", :type => "page", :params => "lightwindow_form=widget_edit_form,lightwindow_width=610", :id => "edit_widget_#{widget.id}", :alt =>t('ubiquo.design.widget_translate'), :title=>t('ubiquo.design.widget_translate')
            end
          end
          def uhook_load_widgets(block)
            block.widgets.locale(current_locale, :all)
          end
        end
      end

      module UbiquoWidgetsController
        def self.included(klass)
          klass.send(:include, InstanceMethods)
          I18n.register_uhooks klass, InstanceMethods
          klass.send(:helper, Helper)
        end
        module InstanceMethods
          include Standard::UbiquoWidgetsController::InstanceMethods

          # modify the created widget and return it. It's executed in drag-drop.
          def uhook_prepare_widget(widget)
            widget.locale = widget.is_configurable? ? current_locale : 'any'
            widget
          end

          # Destroys a widget
          def uhook_destroy_widget(widget)
            widget.destroy_content
          end

          # updates a widget.
          # Fields can be found in params[:widget] and widget_id in params[:id]
          # must returns the updated widget
          def uhook_update_widget
            widget = ::Widget.find(params[:id])
            if current_locale != widget.locale
              widget = widget.translate(current_locale, :copy_all => true)
              widget.locale = current_locale
            end
            params[:widget].each do |field, value|
              widget.send("#{field}=", value)
            end
            widget.save
            widget
          end
        end
        module Helper
          def uhook_extra_rjs_on_update(page, valid)
            yield page
            if @widget.id
              page.replace "edit_widget_#{params[:id]}", uhook_link_to_edit_widget(@widget)
              page << "myLightWindow._processLink($('edit_widget_#{@widget.id}'));" if @widget.is_configurable?
            end
          end
        end
      end

      module UbiquoStaticPagesController
        def self.included(klass)
          klass.send(:include, InstanceMethods)
          klass.send(:helper, Helper)
          I18n.register_uhooks klass, InstanceMethods
        end

        module Helper
          def uhook_static_page_actions(page)
            if page.uhook_static_section_widget(current_locale)
              edit_link = link_to(t('ubiquo.edit'), ubiquo.edit_static_page_path(page))
            else
              edit_link = link_to(t('ubiquo.translate'),
                                  ubiquo.edit_static_page_path(page, :from => page.uhook_static_section_widget(:all).try(:content_id)))
            end
            [
              edit_link,
              (link_to(t('ubiquo.remove'), ubiquo.static_page_path(page), :data => {:confirm => t('ubiquo.design.confirm_page_removal')}, :method => :delete) unless page.key?)
            ].compact
          end
        end

        module InstanceMethods
          def uhook_new_widget
            ::StaticSection.translate(params[:from], current_locale, :copy_all => true)
          end

          def uhook_create_widget
            default_widget_params = {
              :name => t('ubiquo.design.static_pages.widget_title'),
              :locale => current_locale,
            }
            ::StaticSection.new(params[:static_section].reverse_merge!(default_widget_params))
          end
        end

      end

      module RenderPage

        def self.included(klass)
          klass.send(:include, InstanceMethods)
          I18n.register_uhooks klass, InstanceMethods
        end

        module InstanceMethods
          def uhook_collect_widgets(b, &block)
            b.widgets.locale(current_locale).collect(&block)
          end

          def uhook_root_menu_items
            ::MenuItem.locale(current_locale).roots.active
          end

        end
      end

      module Migration

        def self.included(klass)
          klass.send(:extend, ClassMethods)
          I18n.register_uhooks klass, ClassMethods
        end

        module ClassMethods
          include Standard::Migration::ClassMethods

          def uhook_create_widgets_table
            create_table :widgets, :translatable => true do |t|
              yield t
            end
          end
        end
      end

    end
  end
end
