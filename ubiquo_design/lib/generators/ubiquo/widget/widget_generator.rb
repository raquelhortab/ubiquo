# -*- encoding: utf-8 -*-

require 'rails/generators'
require 'rails/generators/named_base'

module Ubiquo
  class WidgetGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    argument :attributes,
              type:    :array,
              default: [],
              banner:  "field[:type] field[:type]"

    def create_model_file
      template 'models/widget.rb.tt', "app/models/widgets/#{file_path}.rb"
    end

    def create_widget_file
      template 'widget.rb.tt', "app/widgets/#{file_path}_widget.rb"
    end

    def create_view_files
      directory 'views', "app/views/widgets/#{file_path}"
    end

    def create_test_files
      directory 'test', 'test'
    end

    def create_i18n_files
      %w(ca en es).each do |locale|
        template_path    = 'locale.yml.tt'
        destination_path = "config/locales/#{locale}/widgets/#{file_path}.yml"

        template template_path, destination_path  do |content|
          locale + content
        end
      end
    end
  end
end
