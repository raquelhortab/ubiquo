# -*- encoding: utf-8 -*-

module Ubiquo
  module Generators
    module Actions

      def ubiquo_tab(name)
        sentinel = /([\t| ]*)(#{Regexp.escape('end # Last tab')})/mi
        tab_file = 'app/views/navigators/_main_navtabs.html.erb'

        log :tabs, "insert #{name} tab"
        in_root do
          inject_into_file tab_file, :before => sentinel do
            "\\1#{tab_template(name)}\n"
          end
        end
      end

      def ubiquo_migration
        rake 'db:migrate'
      end

      def namespaced_route_resources(namespace, *resources)
        scoped_route_resources(namespace, 'namespace', *resources)
      end

      def scoped_route_resources(_scope, kind = 'scope', *resources)
        resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
        sentinel      = "#{kind} :#{_scope} do"
        flag          = /([\t| ]*)(#{Regexp.escape(sentinel)})/mi
        routing_code  = "resources #{resource_list}"

        log :route, routing_code

        in_root do
          inject_into_file 'config/routes.rb', :after => flag do
            "\n\\1  #{routing_code}"
          end
        end
      end

      def ubiquo_route_resources(*resources)
        scoped_route_resources('ubiquo', 'scope', *resources)
      end

      def nested_route_resources(parent, *resources)
        resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')

        new_flag = /([\t| ]*)(resource[s]?\s[\:|]#{parent}?)(\sdo)$/mi
        ext_flag = /([\t| ]*)(resource[s]?\s[\:|]#{parent}?)$/mi

        routing_code = "resources #{resource_list}"

        log :route, routing_code

        in_root do
          inject_into_file 'config/routes.rb', :after => new_flag do
            "\n\\1  #{routing_code}\n"
          end

          gsub_file 'config/routes.rb', ext_flag do |resource|
            spaces = resource.match(ext_flag)[1]
            resource << " do\n#{spaces}  #{routing_code}\n#{spaces}end"
          end
        end
      end

      protected

      def tab_template(name)
        "end

        navigator.add_tab do |tab|
          tab.text  = t('ubiquo.#{name.singularize}.title')
          tab.title = t('application.goto', :place => '#{name}')
          tab.link  = ubiquo_#{name}_path
          tab.highlights_on(:controller => 'ubiquo/#{name}')
          tab.highlighted_class = 'active'"
      end

    end
  end
end
