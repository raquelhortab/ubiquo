# See ubiquo_core guide for more information about filters.
# For edge: http://guides.ubiquo.me/edge/ubiquo_core.html

module Ubiquo
  module Filters

    class UbiquoFilterError < StandardError; end
    class UnknownFilter < UbiquoFilterError; end
    class MissingFilterSetDefinition < UbiquoFilterError; end

    class FilterSetBuilder

      attr_reader :filters

      def initialize(model, context)
        @model = model.constantize
        @context = context
        @filters = []
      end

      def method_missing(method, *args, &block)
        filter = get_filter_class(method).new(@model, @context)
        filter.configure(*args,&block)
        @filters << filter
      end

      # Renders all filters of the set, in order, as a string
      def render
        @filters.map { |f| f.render }.join("\n").html_safe
      end

      # Renders the human message, associated with active filters of
      # the set, as a string
      def message
        info_messages = @filters.inject([]) do |result, filter|
          result << filter.message
        end
        build_filter_info(info_messages)
      end

      private

      def build_filter_info(info_messages)
        fields, string = process_filter_info(info_messages)
        return unless fields
        info = @context.content_tag(:strong, string)
        # Remove keys from applied filters and other unnecessary keys (commit, page, ...)
        remove_fields = fields + [:commit, :page]
        new_params = @context.params.clone
        remove_fields.each { |field| new_params[field] = nil }
        link_text = I18n.t('ubiquo.filters.remove_all_filters', :count => fields.size)
        message = [ I18n.t('ubiquo.filters.filtered_by', :field => info), @context.link_to(link_text, new_params, :class => 'bt-remove-filters')]
        @context.content_tag(:p, message.join(" "), :class => 'search_info')
      end

      # Return the pretty filter info string
      #
      # info_and_fields: array of [info_string, fields_for_that_filter]
      def process_filter_info(info_and_fields)
        info_and_fields.compact!
        return if info_and_fields.empty?
        # unzip pairs of [text_info, fields_array]
        strings, fields0 = info_and_fields[0].zip(*info_and_fields[1..-1])
        fields = fields0.flatten.uniq
        [fields, string_enumeration(strings)]
      end

      # From an array of strings, return a human-language enumeration
      def string_enumeration(strings)
        strings.reject(&:empty?).to_sentence()
      end

      # Given a filter_for method name returns the appropiate filter class
      def get_filter_class(filter_name)
        camel_cased_word = "Ubiquo::Filters::#{filter_name.to_s.classify}Filter"
        camel_cased_word.split('::').inject(Object) do |constant, name|
          constant = constant.const_get(name)
        end
      end

    end

    # Defines a filter set. For example:
    #  # app/helpers/ubiquo/articles_helper.rb
    #  module Ubiquo::ArticlesHelper
    #    def article_filters
    #       filters_for 'Article' do |f|
    #         f.text
    #         f.locale
    #         f.date
    #         f.select :name, @collection
    #         f.boolean :status
    #       end
    #    end
    #  end
    def filters_for(model,&block)
      raise ArgumentError, "Missing block" unless block
      filter_set = FilterSetBuilder.new(model, self)
      yield filter_set
      @filter_set = filter_set
    end

    # Render  a filter set
    def show_filters
      initialize_filter_set_if_needed
      @filter_set.render
    end

    # Render a filter set human message
    def show_filter_info
      initialize_filter_set_if_needed
      @filter_set.message
    end

    private

    # Initializes filter set definition if it isn't already.
    # We need to do this because sometimes we need to render the
    # messages before filters are defined.
    # So if we don't have a filter set we try to run the helper
    # method we expect that will define them.
    #
    # Ex: For the articles_controller we will execute the
    # article_filters method to load the filter set definition.
    #
    # Thanks to this trick we avoid to define filters two times one
    # for messages and one for render.
    def initialize_filter_set_if_needed
      helper = "#{controller.controller_name.singularize}_filters"
      send(helper) unless @filter_set
    end

  end
end

Ubiquo::Extensions::Loader.append_helper(:UbiquoController, Ubiquo::Filters)
