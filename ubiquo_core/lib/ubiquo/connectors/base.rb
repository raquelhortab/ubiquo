module Ubiquo
  module Connectors
    class Base

      # Load all the modules that conform a connector and perform any other necessary task
      def self.load!; end

      # Returns the currently set connector
      def self.current_connector
        @current_connector
      end

      # Changes the currently set connector to +klass+
      def self.set_current_connector klass
        @current_connector = klass
      end

      # Possible cleanups to perform
      def self.unload!; end

      # Register the uhooks methods in connectors to be used in klass
      def self.register_uhooks klass, *connectors
        connectors.each do |connector|
          connector.instance_methods.each do |method|
            if method =~ /^uhook_(.*)$/
              connectorized_method = "uhook_#{self.to_s.demodulize.underscore}_#{$~[1]}"
              connector.send :alias_method, connectorized_method, method
              if klass.instance_methods.include?(method)
                klass.send :alias_method, method, connectorized_method
              else
                class << klass
                  self
                end.send :alias_method, method, connectorized_method
              end
              connector.send :undef_method, connectorized_method
            end
          end
        end
      end

      # Registers a uhook call and keeps a registry of this
      #
      #   parameters: List of parameters that will be recorded along with the call
      #   replace_block: Optional block that will be called for each previous call to this function.
      #                  If it returns true, the previous call will be deleted
      def self.register_uhook_call *parameters, &replace_block
        # make sure we are registering at Base and not in a subclass
        uhook_calls = Base.instance_variable_get('@uhook_calls')
        uhook_calls ||= {}
        caller[0]=~/`(.*?)'/
        if replace_block
          (uhook_calls[$1.to_sym] ||= []).reject!{ |prev_call| replace_block.call(prev_call)}
        end
        (uhook_calls[$1.to_sym] ||= []) << parameters
        Base.instance_variable_set('@uhook_calls', uhook_calls)
      end

      # Returns the list of calls for this method
      def self.get_uhook_calls method
        Array((Base.instance_variable_get('@uhook_calls')||{})[method.to_sym])
      end

      # Validate here the possible connector requirements and dependencies
      def self.validate_requirements; end

      # Load any test mock needed for base tests
      # If your connector calls to a method that will be undefined in test time,
      # using this method you can mock them to allow it pass.
      def self.prepare_mocks; end

      # Prepared helper stubs for this connector
      class << self
        attr_accessor :mock_helper_stubs
      end

      # Used to add particular helper expectations from the connectors
      # Usually called from prepare_mocks
      def self.add_mock_helper_stubs(methods_with_returns)
        future_stubs = (mock_helper_stubs || {}).merge(methods_with_returns)
        self.mock_helper_stubs = future_stubs
      end

      # Validates the ubiquo_i18n-related dependencies
      # Returning false will halt the connector load
      def self.validate_i18n_requirements(*models)
        unless Ubiquo::Plugin.registered[:ubiquo_i18n]
          unless Rails.env.test?
            raise ConnectorRequirementError, "You need the ubiquo_i18n plugin to load #{self}"
          else
            return false
          end
        end
        models.each do |model|
          ([model] + model.send(:subclasses)).each do |klass|
            ensure_table_is_i18n_enabled(klass)
          end
        end
      end

      def self.ensure_table_is_i18n_enabled(model)
        if model.table_exists?
          model_columns = model.columns.map(&:name).map(&:to_sym)
          unless [:locale, :content_id].all?{|field| model_columns.include? field}
            if Rails.env.test?
              ::ActiveRecord::Base.connection.change_table(model.table_name, :translatable => true){}
              if ::ActiveRecord::Base.connection.class.included_modules.include?(Ubiquo::Adapters::Mysql)
                # "Supporting" DDL transactions for mysql
                ::ActiveRecord::Base.connection.begin_db_transaction
                ::ActiveRecord::Base.connection.create_savepoint
              end
              model.reset_column_information
            else
              raise ConnectorRequirementError,
              "The #{model.table_name} table does not have the i18n fields. " +
                "To use this connector, update the table enabling :translatable => true"
            end
          end
        end
      end

      # Raised when a connector requirement is not met
      class ConnectorRequirementError < StandardError; end

    end
  end
end
