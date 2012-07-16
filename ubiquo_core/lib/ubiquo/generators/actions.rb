# -*- encoding: utf-8 -*-

module Ubiquo
  module Generators
    module Actions

      def ubiquo_tab(name)
        flag     = 'end # :flag:'
        sentinel = /([\t| ]*)(#{Regexp.escape(flag)})/mi
        tab_file = 'app/views/navigators/_main_navtabs.html.erb'

        log :tabs, "insert #{name} tab"
        in_root do
          inject_into_file tab_file, :before => sentinel do
            tab_template(name)
          end
        end
      end

      def tab_template(name)
        [
          "end",
          "",
          "navigator.add_tab do |tab|",
          "  tab.text  = t('ubiquo.#{name.singularize}.title')",
          "  tab.title = t('application.goto', :place => '#{name}')",
          "  tab.link  = ubiquo.#{name}_path",
          "  tab.highlights_on(:controller => 'ubiquo/#{name}')",
          "  tab.highlighted_class = 'active'",
        ].map { |l| l.blank? ? "#{l}\n" : "    #{l}\n" }.reduce(:+)
      end
      protected :tab_template

      def ubiquo_migration *args
        if behavior == :revoke
          # Thor's +run+ won't do anthing unless the behavior is :invoke... wat
          self.behavior = :invoke
          rake 'db:rollback'
          self.behavior = :revoke
        else
          rake 'db:migrate'
        end
      end

      def ubiquo_route_resources(*resources)
        scoped_route_resources('ubiquo', *resources)
      end

      def scoped_route_resources(namespace, *resources)
        _route_resources(namespace, *resources, :kind => 'scope')
      end

      def namespaced_route_resources(namespace, *resources)
        _route_resources(namespace, *resources, :kind => 'namespace')
      end

      def _route_resources(_scope, *arguments)
        options   = arguments.extract_options!
        kind      = options[:kind] || 'scope'
        resources = arguments.dup

        resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
        sentinel      = "#{kind} :#{_scope} do"
        flag          = /([\t| ]*)(#{Regexp.escape(sentinel)})/mi
        routing_code  = "resources #{resource_list}"

        log :route, routing_code

        in_root do
          inject_into_file 'config/routes.rb', :after => flag do
            "\n      #{routing_code}"
          end
        end
      end
      protected :_route_resources

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
            resource << " do\n\\1  #{routing_code}\n\\1end"
          end
        end
      end

    end
  end
end
