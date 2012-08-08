# -*- encoding: utf-8 -*-

require 'rails/generators'
require 'rails/generators/named_base'
require 'ubiquo/generators'

module UbiquoScaffold
  module Generators
    class Base < ::Rails::Generators::NamedBase
      include ::Ubiquo::Generators::Actions

      SPECIAL_LABELS = [:title, :name]

      argument :attributes,
               type:    :array,
               default: [],
               banner:  "field[:type] field[:type]"

      class_option :migration,
                   desc:    "Generate a migration file for this model",
                   type:    :boolean,
                   default: true
      class_option :fixtures,
                   desc:    "Generates a fixture file for this model",
                   type:    :boolean,
                   default: true
      class_option :timestamps,
                   desc:    "Adds timestamps to the migration file for this model",
                   type:    :boolean,
                   default: true

      class_option :belongs_to,
                   desc:     "Creates belongs_to relations between model and f1, f2...",
                   banner:   "[f1 f2]",
                   type:     :array,
                   required: false
      class_option :has_many,
                   desc:     "Creates has_many relations between model and f1, f2...",
                   banner:   "[f1 f2]",
                   type:     :array,
                   required: false

      class_option :versionable,
                   desc:     "Creates a versionable model",
                   type:     :boolean,
                   required: false
      class_option :max_versions_amount,
                   desc:     "Sets the max amount of versions if the model is versionable",
                   type:     :numeric,
                   required: false

      class_option :translatable,
                   desc:     "Adds translatable fields",
                   banner:   "[field field]",
                   type:     :array,
                   required: false

      class_option :categorized,
                   desc:     "Creates category relations with f1, f2...",
                   banner:   "[f1 f2]",
                   type:     :array,
                   required: false

      class_option :media,
                   desc:     "Creates media relations with f1, f2...",
                   banner:   "[f1 f2]",
                   type:     :array,
                   required: false

      class_option :nested_from,
                   desc:     "Adds the generated resource under an existing parent",
                   banner:   "parent_resource",
                   type:     :string,
                   required: false

      class_option :run_migration,
        desc: "Run pending migrations at the end",
        type: :boolean,
        default: !Rails.env.test?

      def self.source_root
        path = File.join(File.dirname(__FILE__), 'ubiquo', generator_name, 'templates')

        @_source_root ||= File.expand_path(path)
      end

      protected

      def labeled?
        attribute_names.each do |name|
          return true if SPECIAL_LABELS.include?(name.to_sym)
        end

        false
      end

      def label_name
        SPECIAL_LABELS.find { |o| attribute_names.include?(o) }
      end

      def attribute_names
        @names ||= respond_to?(:attributes) ? attributes.map(&:name).map(&:to_sym) : []
      end

      def has_published_at?
        attributes.find do |a|
          a.name == 'published_at' && (a.type == :date || a.type == :datetime)
        end
      end
    end
  end
end
