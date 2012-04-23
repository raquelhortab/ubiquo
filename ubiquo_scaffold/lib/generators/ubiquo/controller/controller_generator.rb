# -*- encoding: utf-8 -*-

module Ubiquo
  class ControllerGenerator < UbiquoScaffold::Generators::Base

    class_option :skip_activity,
                 desc:    "Doesn't add activity control to the generated controller",
                 type:    :boolean,
                 default: false

    def create_controller_file
      template 'controller.rb.tt', "app/controllers/ubiquo/#{controller_file_path}.rb"
    end

    def create_view_files
      ubiquo_tab plural_name
      directory 'views/navigators', 'app/views/navigators'
      directory 'views/ubiquo', "app/views/ubiquo/#{namespaced_path}"
    end

    def create_helper_file
      template 'helper.rb.tt', "app/helpers/ubiquo/#{namespaced_path}#{plural_name}_helper.rb"
    end

    def create_functional_test_file
      template 'functional_test.rb.tt', "test/functional/ubiquo/#{namespaced_path}#{controller_file_name}_test.rb"
    end

    def create_helper_test_file
      template 'helper_test.rb.tt', "test/unit/helpers/ubiquo/#{namespaced_path}#{plural_name}_helper_test.rb"
    end

    def create_i18n_files
      directory 'locales', 'config/locales'
    end

    def add_ubiquo_routes
      if options[:nested_from]
        nested_route_resources options[:nested_from], plural_name
      else
        ubiquo_route_resources plural_name
      end
    end

    protected

    # helper methods

    def namespaced_path
      path = regular_class_path.join('/')

      path.blank? ? '' : "#{path}/"
    end

    def controller_class_name
      "#{class_name.pluralize}Controller"
    end

    def controller_file_name
      "#{plural_name}_controller"
    end

    def controller_file_path
      "#{namespaced_path}#{controller_file_name}"
    end

    def include_tiny_mce?
      attributes.map(&:field_type).include? :text_area
    end

    def register_activity?
      # TODO: add ubiquo_activity check
      !options[:skip_activity]
    end
  end
end
