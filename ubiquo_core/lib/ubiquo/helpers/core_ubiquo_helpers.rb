module Ubiquo
  module Helpers
    module CoreUbiquoHelpers

      class AssociationNotFound < StandardError; end

      class UbiquoStylesheetIncludeTag < ActionView::Helpers::AssetTagHelper::StylesheetIncludeTag
        def custom_dir

        end
      end

      # Removes the non existent assets in the asset environment.
      def filter_assets(assets, format)
        env = asset_environment rescue {}
        assets.select{ |a| env["#{a.to_s}.#{format}"] }
      end

      # Adds the default stylesheet tags needed for ubiquo
      # options:
      #   color: by default is red, but you can replace it calling another color
      #          css file
      #   rest of options: this helper doesn't user more options, the rest are
      #                    send to stylesheet_link_tag generic helper
      def ubiquo_stylesheet_link_tag(*sources)
        options = sources.extract_options!.stringify_keys
        color = options.delete("color") || :red
        default_sources = []
        should_include_ie = false
        if sources.include?(:defaults)
          default_sources += filter_assets(Ubiquo::Plugin.registered_plugins.map(&:to_s), 'css')
          default_sources += ["ubiquo/colors/#{color}", "ubiquo/ubiquo_application"]
          # on tests, there might be no request or no user_agent method
          default_sources += ["ubiquo/ipad"] if request.user_agent.match(/Apple.*Mobile/) rescue false
          should_include_ie = true
          sources.delete(:defaults)
        end
        ubiquo_sources = sources.map{ |s| "ubiquo/#{s}"} + default_sources
        output = stylesheet_link_tag(*ubiquo_sources, options)

        if should_include_ie
          ie_output = <<-eos
            <!--[if IE]>
              #{stylesheet_link_tag 'ubiquo/ubiquo_ie'}
            <![endif]-->
          eos
          [output, ie_output].join("\n").html_safe
        else
          output
        end

      end

      def ubiquo_javascript_include_tag(*sources)
        options = sources.extract_options!.stringify_keys
        default_sources = []
        if sources.include?(:defaults)
          default_sources += Ubiquo::Plugin.registered_plugins + ["ubiquo/ubiquo_application"]
          sources.delete(:defaults)
        end
        ubiquo_sources = filter_assets(sources.map{ |s| "ubiquo/#{s}"} + default_sources, "js")
        javascript_include_tag(*ubiquo_sources, options).html_safe
      end

      # surrounds the block between the specified box.
      def box(name, options={}, &block)
        options.merge!(:body=>capture(&block))
        concat(render(:partial => "shared/ubiquo/boxes/#{name}", :locals => options), block.binding)
      end

      # This is a wrapper for image_tag for images inside the "ubiquo" directory
      # This folder can be changed using the :ubiquo_path configuration option
      def ubiquo_image_tag(source, options={})
        image_tag(ubiquo_image_path(source), options)
      end

      # Returns the path for an ubiquo image
      def ubiquo_image_path(name)
        "#{Ubiquo::Settings.get(:ubiquo_path)}/#{name}"
      end

      # Returns a "tick" or "cross" image, useful to display boolean values
      def ubiquo_boolean_image(value)
        content_tag(:span, value, :class => "state_#{value}")
      end

      # Returns a properly marked up ubiquo sidebar box.
      # Used to display sidebar items like filters, help boxes, etc.
      def ubiquo_sidebar_box(title, options, &block)
        css_class = "sidebar_box #{options[:class]}".strip
        extra_header = options[:extra_header] || ''
        content_tag(:div, :class => css_class, :id => options[:id]) do
          content_tag(:div, :class => "header") do
            content_tag(:h3, title) + extra_header
          end + \
          content_tag(:div, capture(&block), :class => "content")
        end
      end

      # Return true if string_date is a valid date representation with a
      # given format (the so-called italian format by default: %d/%m/%Y)
      def is_valid_date?(string_date, format="%d/%m/%Y")
        begin
          time = Date.strptime(string_date, format)
        rescue ArgumentError
          return false
        end
        true
      end

      # Include calendar_date_select javascript and stylesheets
      # with a default theme, basedir and locale
      def calendar_includes(options = {})
        iso639_locale = options[:locale] || I18n.locale.to_s
        ::CalendarDateSelect.format = options[:format] || :italian
        calendar_date_select_includes "ubiquo", :locale => iso639_locale
      end

      # Renders a message in a help block in the sidebar
      def help_block_sidebar(message)
        ubiquo_sidebar_box(t("ubiquo.help"), :class => "help-box") do
          content_tag(:p, message)
        end
      end

      # Renders a preview
      # A preview is usually used to show the values of an instance somewhere,
      # in an unobtrusive way
      # The instance to preview is taken from params[:preview_id]
      def show_preview(model_class, options = {}, &block)
        return unless params[:preview_id]
        previewed = model_class.find(params[:preview_id], options)
        return unless previewed
        locals = {:body=>capture(previewed, &block)}
        concat(render(:partial => "shared/ubiquo/preview_box", :locals => locals))
      end

      # converts symbol to ubiquo standard table head with order_by and sort_order strings
      def ubiquo_table_headerfy(column, klass=nil, options={})
        name = klass.nil? ? params[:controller].split("/").last.tableize : klass
        case column
          when Symbol
            link = params.clone
            column_to_filter = column.to_s.gsub('._', '.')
            if link[:order_by] == "#{name.to_s.pluralize}.#{column_to_filter}"
              link[:sort_order] = link[:sort_order] == "asc" ? "desc" : "asc"
            else
              link[:order_by] = "#{name.pluralize}.#{column_to_filter}"
              link[:sort_order] = "asc"
            end
            #name.classify.human_attribute_name(column.to_s.humanize)
            #t("#{name.classify}|#{column.to_s.humanize}").humanize

            column_segments = column.to_s.split('.') # Example column: :"author.name"
            column_header = if options[:column_header]
              options[:column_header]
            elsif column_segments.size > 1
              begin
                # Here we are dealing with relation columns
                if column_segments.last[0] == '_'
                  name.classify.constantize.human_attribute_name(column_segments.last.sub(/^_/, ''))
                else
                  assoc_model = name.classify.constantize.reflections[column_segments.first.to_sym].klass
                  assoc_model.human_name.downcase
                end
              rescue NameError
                # Here we are dealing with relation columns using categories
                category = CategorySet.find_by_key(column_segments.first)
                msg = "Couldn't find #{column_segments.first} association."
                raise AssociationNotFound, msg unless category
                category.name
              end
            else
              name.classify.constantize.human_attribute_name(column.to_s)
            end

            link_to content_tag(:span, column_header),
                    link,
                    { :class => (params[:order_by] == "#{name.pluralize}.#{column_to_filter}" ?
                                (params[:sort_order] == "asc" ? "order_desc" : "order_asc") : "order" )}
          when String
            column.humanize
          when Hash
            ubiquo_table_headerfy(column[:key].to_sym, klass, column_header: column[:column_header])
        end
      end

      # Method to activate the usage of the ubiquo form builder
      def ubiquo_form_for(record_or_name_or_array, *args, &proc)
        opts = (args.last || {})
        opts[:builder] = UbiquoFormBuilder
        args << opts if !args.last
        form_for(record_or_name_or_array, *args, &proc)
      end

      # Copy of the original error_messages_for from the 2.3.8 version
      #
      # TODO: This must be adapted to our needs or deleted on the views and use
      #       something like this:
      #
      #       <% if @object.errors.any? %>
      #         <ul>
      #           <% @object.errors.full_messages.each do |msg| %>
      #             <li><%= msg %></li>
      #           <% end %>
      #         </ul>
      #       <% end %>
      def error_messages_for(*params)
        options = params.extract_options!.symbolize_keys

        if object = options.delete(:object)
          objects = Array.wrap(object)
        else
          objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
        end

        count  = objects.inject(0) {|sum, object| sum + object.errors.count }
        unless count.zero?
          html = {}
          [:id, :class].each do |key|
            if options.include?(key)
              value = options[key]
              html[key] = value unless value.blank?
            else
              html[key] = 'errorExplanation'
            end
          end
          options[:object_name] ||= params.first

          I18n.with_options :locale => options[:locale], :scope => [:activerecord, :errors, :template] do |locale|
            header_message = if options.include?(:header_message)
              options[:header_message]
            else
              object_name = options[:object_name].to_s
              object_name = I18n.t(object_name, :default => object_name.gsub('_', ' '), :scope => [:activerecord, :models], :count => 1)
              locale.t :header, :count => count, :model => object_name
            end
            message = options.include?(:message) ? options[:message] : locale.t(:body)
            error_messages = objects.sum {|object| object.errors.full_messages.map {|msg| content_tag(:li, ERB::Util.html_escape(msg)) } }.join.html_safe

            contents = ''
            contents << content_tag(options[:header_tag] || :h2, header_message) unless header_message.blank?
            contents << content_tag(:p, message) unless message.blank?
            contents << content_tag(:ul, error_messages)

            content_tag(:div, contents.html_safe, html)
          end
        else
          ''
        end
      end
    end
  end
end
