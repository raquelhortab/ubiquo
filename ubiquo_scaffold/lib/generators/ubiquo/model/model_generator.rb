# -*- encoding: utf-8 -*-

module Ubiquo
  class ModelGenerator < UbiquoScaffold::Generators::Base
    include ::Rails::Generators::Migration

    # Implement the required interface for Rails::Generators::Migration.
    # taken from:
    # http://github.com/rails/rails/blob/master/activerecord/lib/generators/active_record.rb
    def self.next_migration_number(dirname)
      if ActiveRecord::Base.timestamped_migrations
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      else
        "%.3d" % (current_migration_number(dirname) + 1)
      end
    end

    # file creations
    def create_model_file
      template 'model.rb.tt', "app/models/#{file_path}.rb"
    end

    def create_migration_file
      if options[:migration]
        migration_template 'migration.rb.tt', "db/migrate/create_#{file_name.pluralize}.rb"
      end
    end

    def create_unit_test_file
      template 'unit_test.rb.tt', "test/unit/#{file_path}_test.rb"

      if options[:fixtures]
        template 'fixtures.yml.tt', "test/fixtures/#{table_name}.yml"
      end
    end

    def create_i18n_files
      locales.each do |locale|
        @current_locale = locale
        template 'i18n.yml.tt', "config/locales/#{locale}/models/#{file_path}.yml"
      end
    end

    protected

    # helper methods

    def classes_for_has_many
      options[:has_many] ? options[:has_many].map(&:classify) : Array.new
    end

    def belongs_to_field
      "#{file_name}_id"
    end

    def translated_attributes
      attributes.inject([]) do |a, attribute|
        name = attribute.name
        if @current_locale.present? && field_translations.has_key?(name.to_sym)
          translation = field_translations[name.to_sym][@current_locale.to_sym]
        else
          translation = name.humanize
        end

        a << { name: name, translation: translation }
        a
      end
    end

    def field_translations
      @translations ||= {
        title:        { ca: 'Títol', es: 'Título', en: 'Title' },
        name:         { ca: 'Nom', es: 'Nombre', en: 'Name' },
        published_at: { ca: 'Data de publicació',
                        es: 'Fecha de publicación',
                        en: 'Published at' }
      }
    end

    def locales
      @locales ||= ubiquo_locales or default_locales
    end

    def ubiquo_locales
      if defined?(Ubiquo) && Ubiquo.respond_to?(:supported_locales)
        Ubiquo.supported_locales.map(&:to_s)
      end
    end

    def default_locales
      %w(ca es en)
    end

    def versionable_options
      amount = options[:max_versions_amount]

      amount ? " max_amount: #{amount}" : ""
    end

    def translatable_options
      if options[:translatable].present?
        options[:translatable].map { |field| ":#{field}" }.join(", ")
      end
    end

    def create_table_options
      _options = []
      _options << key_value('versionable', 'true') if options[:versionable]
      _options << key_value('translatable', 'true') if options[:translatable]
      _options = _options.join(', ')

      _options.present? ? ", #{_options}" : ''
    end

    def keys_for_categories
      options[:categorized] ? options[:categorized].map(&:pluralize) : Array.new
    end

  end
end
