module UbiquoI18n
  module Extensions
    module ActiveRecord

      def self.append_features(base)
        super
        base.extend(ClassMethods)
        base.send :include, InstanceMethods
        base.send :alias_method_chain, :clone, :i18n_fields_ignore
        base.send :alias_method_chain, :assign_attributes, :i18n_fields
      end

      module ClassMethods

        delegate :locale, :localized, :to => :scoped

        # Class method for ActiveRecord that states which attributes are translatable and therefore when updated will be only updated for the current locale.
        #
        # EXAMPLE:
        #
        #   translatable :title, :description
        #
        # possible options:
        #   :timestamps => set to false to avoid translatable (i.e. independent per translation) timestamps

        def translatable(*attrs)

          # inherit translatable attributes
          @translatable_attributes = self.translatable_attributes || []

          @really_translatable_class = self
          @translatable = true

          # add the uniqueness validation, clearing it before if it existed
          clear_locale_uniqueness_per_entity_validation
          add_locale_uniqueness_per_entity_validation

          # extract and parse options
          options = attrs.extract_options!
          # add attrs from this class
          @translatable_attributes += attrs

          # timestamps are independent per translation unless set
          @translatable_attributes += [:created_at, :updated_at] unless options[:timestamps] == false
          # when using optimistic locking, lock_version has to be independent per translation
          @translatable_attributes += [:lock_version]

          # try to generate the attribute setter
          self.new.send(:locale=, :generate) rescue nil
          if instance_methods.include?(:locale=) && !instance_methods.include?(:locale_with_duality=)
            # give the proper behaviour to the locale setter
            define_method('locale_with_duality=') do |locale|
              locale = case locale
              when String
                locale
              else
                locale.iso_code if locale.respond_to?(:iso_code)
              end
              send(:locale_without_duality=, locale)
            end

            alias_method_chain :locale=, :duality

          end

          unless instance_methods.include?(:in_locale)
            define_method('in_locale') do |*locales|
              self.class.locale(*locales).first(:conditions => {:content_id => self.content_id})
            end
          end

          # Checks if the instance has a locale in the given a locales list
          # The last parameter can be an options hash
          #   :skip_any => if true, ignore items with the :any locale.
          #                else, these items always return true
          define_method('in_locale?') do |*asked_locales|
            options = asked_locales.extract_options!
            options.reverse_merge!({
              :skip_any => false
            })
            asked_locales.map(&:to_s).include?(self.locale) ||
              (!options[:skip_any] && self.locale == 'any')
          end

          # usage:
          # find all items of one content: Model.content(1).first
          # find all items of some contents: Model.content(1,2,3)
          scope :content, lambda{|*content_ids|
            where(:content_id => content_ids)
          }

          # usage:
          # find all translations of a given content: Model.translations(content)
          # will use the defined scopes to discriminate what are translations
          # remember it won't return 'content' itself
          scope :translations, lambda{|content|
            scoped_conditions = []
            @translatable_scopes.each do |scope|
                scoped_conditions << (String === scope ? scope : scope.call(content))
            end
            inequality_operator = content.locale ? '!=' : 'IS NOT'
            translation_condition = "#{self.table_name}.content_id = ? AND #{self.table_name}.locale #{inequality_operator} ?"
            unless scoped_conditions.blank?
              translation_condition += ' AND ' + scoped_conditions.join(' AND ')
            end
            where([translation_condition, content.content_id, content.locale])
          }

          # Instance method to find translations
          define_method('translations') do
            self.class.unscoped.translations(self)
          end

          # Returns an array containing self and its translations
          define_method('with_translations') do
            [self] + translations
          end

          # Creates a new instance of the translatable class, using the common
          # values from an instance sharing the same content_id
          # Returns a new independent instance if content_id is nil or not found
          # Options can be one of these:
          #   :copy_all => if true, will copy all the attributes from the original, even the translatable ones
          def translate(content_id, locale, options = {})
            original = find_by_content_id(content_id)
            new_translation = original ? original.translate(locale, options) : new
            new_translation.locale = locale
            new_translation
          end

          # Creates (saving) a new translation of self, with the common values filled in
          define_method('translate') do |*params|
            locale = params.first
            options = params.extract_options!
            copy_all = options[:copy_all].nil? ? true : options[:copy_all]

            new_translation = self.class.new
            new_translation.locale = locale

            # copy of attributes
            clonable_attributes = copy_all ? :attributes_except_unique_for_translation : :untranslatable_attributes
            self.send(clonable_attributes).each_pair do |attr, value|
              new_translation.send("#{attr}=", value)
            end

            new_translation
          end


          # Looks for defined shared relations and performs a chain-update on them
          define_method('copy_translatable_shared_relations_from') do |model|
            # here a clean environment is needed, but save Locale.current
            without_current_locale((self.locale rescue nil)) do
              self.class.translating_relations do
                must_save = false
                self.class.translation_shared_reflections.each do |association_id, reflection|
                  # if this is a has_many :through, we don't do anything;
                  # this implies that the intermediate table is translation-shared,
                  # which we currently enforce in the definition, or else
                  # the propagation of changes would not work
                  next if reflection.has_many_through_translatable?

                  # Get the associated instances as Rails would return it
                  association_values = model.send("#{association_id}")
                  # Use the first record to determine what to do in this association
                  record = [association_values].flatten.first

                  if record
                    all_relationship_contents = [association_values].flatten.reject(&:marked_for_destruction?)
                  elsif reflection.macro == :belongs_to
                     # no record means that we are removing an association, so the new content is nil
                    all_relationship_contents = [nil]
                  else
                    # no values on a has_many or has_one
                    all_relationship_contents = []
                  end

                  all_relationship_contents = all_relationship_contents.first unless association_values.is_a?(Array)

                  # Save the new association contents
                  self.send("#{association_id}=", all_relationship_contents)
                  if reflection.macro == :belongs_to && !new_record?
                    # belongs_to is not autosaved by rails when the association is not new
                    must_save = true
                  end
                end
                save if must_save
              end
            end
          end

          # Do any necessary treatment when we are about to propagate changes from an instance to its translations
          define_method 'prepare_for_shared_translations' do
            # Rails doesn't reload the belongs_to associations when the _id field is changed,
            # which causes cached data to persist when it's already obsolete
            self.class.translation_shared_reflections.select do |name, reflection|
              if reflection.macro == :belongs_to
                refresh_reflection_value_if_needed(reflection)
              end
            end
          end

          define_method "refresh_reflection_value_if_needed" do |reflection|
            if has_updated_existing_primary_key(reflection)
              association = association(reflection.name).without_shared_translations
              association.reload if association
            end
          end

          define_method 'destroy_content' do
            self.translations.each(&:destroy)
            self.destroy
          end

        end

        def untranslatable
          @translatable_attributes = []
          @really_translatable_class = nil
          @translatable = nil
          clear_locale_uniqueness_per_entity_validation
        end

        def initialize_translations_for(*associations)
          share_translations_for(associations, {:only_new => true})
          associations.each do |association|
            ["assign_nested_attributes_for_collection_association"].each do |method|
              unless self.method_defined?("#{method}_with_initialization")
                define_method("#{method}_with_initialization") do |*params|
                  # It's being fully assigned, so should no longer return results as an initialized_shared
                  current_association = params.first
                  association_initialized!(current_association)
                  # If these shared results were already loaded, discard them
                  if self.is_association_initialized?(current_association)
                    self.send(current_association).reset
                  end
                  # Now perform the assignation as usual
                  send("#{method}_without_initialization", *params)
                end
                alias_method_chain("#{method}", :initialization)
              end
            end
          end
        end

        def share_translations_for(*associations)
          options = associations.extract_options!
          associations.flatten.each do |association_id|

            reflection = reflections[association_id] or
              raise ::ActiveRecord::ConfigurationError, "Association named '#{association_id}' was not found"

            reflection.mark_as_translation_shared(true, options)

            unless is_translation_shared_initialized? association_id
              # Marker to avoid recursive redefinition
              initialize_translation_shared association_id

              # For has_many :throughs, the middle must have the same configuration
              # as the end
              if reflection.has_many_through_translatable?
                if reflection.is_translation_shared?
                  share_translations_for reflection.through_reflection.name
                elsif reflection.is_translation_shared_on_initialize?
                  initialize_translations_for reflection.through_reflection.name
                end
              end
            end

          end

        end

        # Reverses the action of +share_translations_for+
        def unshare_translations_for(*associations)
          options = associations.extract_options!
          associations.flatten.each do |association_id|
            if is_translation_shared_initialized? association_id
              reflections[association_id].mark_as_translation_shared(false, options)
              uninitialize_translation_shared association_id
            end
          end
        end

        # Reverses the action of +initialize_translations_for+
        def uninitialize_translations_for(*associations)
          unshare_translations_for associations, {:only_new => true}
        end

        # Given a reflection, will process the :translation_shared option
        def process_translation_shared reflection
          reset_translation_shared reflection.name
          if reflection.is_translation_shared?
            share_translations_for reflection.name
          end
        end

        # Returns the reflections that are translation_shared
        def translation_shared_reflections
          self.reflections.select do |name, reflection|
            reflection.is_translation_shared?
          end
        end

        # Returns the value for the var_name instance variable, or if this is nil,
        # follow the superclass chain to ask the value
        def instance_variable_inherited_get(var_name, method_name = nil)
          method_name ||= var_name
          value = instance_variable_get("@#{var_name}")
          if value.nil? && !@really_translatable_class && self.superclass.respond_to?(method_name)
            self.superclass.send(method_name)
          else
            value
          end
        end

        # Sets the value for the var_name instance variable, or if this is nil,
        # follow the superclass chain to set the value
        def instance_variable_inherited_set(value, var_name, method_name = nil)
          method_name ||= var_name
          if !@really_translatable_class && self.superclass.respond_to?(method_name)
            self.superclass.send(method_name, value)
          else
            instance_variable_set("@#{var_name}", value)
          end
        end

        # Returns true if the class is marked as translatable
        def is_translatable?
          instance_variable_inherited_get("translatable", "is_translatable?")
        end

        # Returns a list of translatable attributes for this class
        def translatable_attributes
          instance_variable_inherited_get("translatable_attributes")
        end

        # Returns the class that really calls the translatable method
        def really_translatable_class
          instance_variable_inherited_get("really_translatable_class")
        end

        # Returns true if this class is currently translating relations
        def is_translating_relations
          instance_variable_inherited_get("is_translating_relations")
        end

        # Sets the value of the is_translating_relations flag
        def is_translating_relations=(value)
          instance_variable_inherited_set(value, "is_translating_relations", "is_translating_relations=")
        end

        # Wrapper for translating relations preventing cyclical chain updates
        def translating_relations
          unless is_translating_relations
            self.is_translating_relations = true
            begin
              yield
            ensure
              self.is_translating_relations = false
            end
          end
        end

        # Returns true if the translatable propagation has been set to stop
        def stop_translatable_propagation
          instance_variable_inherited_get("stop_translatable_propagation")
        end

        # Setter for the stop_translatable_propagation_flag
        def stop_translatable_propagation=(value)
          instance_variable_inherited_set(value, "stop_translatable_propagation", "stop_translatable_propagation=")
        end

        # Returns true if the translation-shared association has been initialized
        def is_translation_shared_initialized? association_id = nil
          associations = initialized_translation_shared_list
          associations.is_a?(Array) && associations.include?(association_id)
        end

        # Returns the list of associations initialized
        def initialized_translation_shared_list
          instance_variable_inherited_get("initialized_translation_shared_list")
        end

        # Marks the association as initialized
        def initialize_translation_shared association_id
          new_association = Array(association_id)
          associations = instance_variable_inherited_get("initialized_translation_shared_list") || []
          associations +=  new_association
          instance_variable_inherited_set(associations, "initialized_translation_shared_list", "initialize_translation_shared")
        end

        # Unmarks the association as non-initialized (reverse of +initialize_translation_shared+)
        def uninitialize_translation_shared association_id
          initialized_associations = instance_variable_inherited_get("initialized_translation_shared_list") || []
          initialized_associations.delete(association_id)
        end

        # Unmarks an association as translation-shared initialized
        def reset_translation_shared association_id
          reset_association = Array(association_id)
          associations = instance_variable_inherited_get("initialized_translation_shared_list") || []
          associations -=  reset_association
          instance_variable_inherited_set(associations, "initialized_translation_shared_list", "reset_translation_shared")
        end

        # Attributes that are always 'translated' (not copied between languages)
        (@global_translatable_attributes ||= []) << :locale << :content_id

        # Used by third parties to add fields that should always
        # be independent between different languages
        def add_translatable_attributes(*args)
          @global_translatable_attributes += args
        end

        # Define scopes to limit the automatic update of common fields to instances
        # that have the same value for each scope (as a field name)
        @translatable_scopes ||= []

        # Used by third parties to add scopes for translations updates of common fields
        # It accepts two formats for condition:
        # - A String with a sql where condition (e.g. is_active = 1)
        # - A Proc that will be called with the current element argument and
        #   that should return a string (e.g. lambda{|el| "table.field = #{el.field + 1}"})
        def add_translatable_scope(condition)
          @translatable_scopes << condition
        end

        @@translatable_inheritable_instance_variables = %w{global_translatable_attributes translatable_scopes}

        def self.extended(klass)
          # Ensure that the needed variables are inherited
          @@translatable_inheritable_instance_variables.each do |inheritable|
            unless eval("@#{inheritable}").nil?
              klass.instance_variable_set("@#{inheritable}", eval("@#{inheritable}").dup)
            end
          end

          # Accept the :translation_shared option when defining associations
          association_builder = ::ActiveRecord::Associations::Builder::Association
          ([association_builder] + association_builder.descendants).each do |builder|
            builder.valid_options << :translation_shared
          end
        end

        def inherited(klass)
          super
          @@translatable_inheritable_instance_variables.each do |inheritable|
            unless eval("@#{inheritable}").nil?
              klass.instance_variable_set("@#{inheritable}", eval("@#{inheritable}").dup)
            end
          end
        end

        def clear_validation identifier
          self._validators[:locale].reject! do |validator|
            validator.options[:identifier] == identifier
          end
          self._validate_callbacks.reject! do |validator|
            validator.options[:identifier] == identifier
          end
        end

        def uniqueness_per_entity_validation_identifier
          :locale_uniqueness_per_entity
        end

        def clear_locale_uniqueness_per_entity_validation
          clear_validation uniqueness_per_entity_validation_identifier
        end

        # Assure no duplicated objects for the same locale
        def add_locale_uniqueness_per_entity_validation
          validates_uniqueness_of(
            :locale,
            :identifier => uniqueness_per_entity_validation_identifier,
            :scope => :content_id,
            :case_sensitive => false,
            :message => Proc.new { |*attrs|
              locale = attrs.last[:value] rescue false
              humanized_locale = Locale.find_by_iso_code(locale.to_s)
              humanized_locale = humanized_locale.native_name if humanized_locale
              I18n.t(
                'ubiquo.i18n.locale_uniqueness_per_entity',
                :model => self.model_name.human,
                :object_locale => humanized_locale
              )
            }
          )
        end

        private

        def merge_locale_list locales
          merge_locale_list_rec locales.first, locales[1,locales.size]
        end

        def merge_locale_list_rec previous, rest
          new = rest.first
          return previous.clone unless new
          merged = if previous.empty? || previous.include?(:all)
            new
          else
            previous & new
          end
          merged = previous if merged.empty? && new.include?(:all)
          merge_locale_list_rec merged, rest[1,rest.size]
        end

      end

      module InstanceMethods

        def self.included(klass)
          klass.send :before_validation, :initialize_i18n_fields
          klass.alias_method_chain :update, :translatable
          klass.alias_method_chain :create, :translatable
          klass.alias_method_chain :create, :i18n_fields
        end

        def is_association_initialized?(association)
          self.instance_variable_get("@#{association}_initialized")
        end

        def association_initialized!(association)
          self.instance_variable_set("@#{association}_initialized", true)
        end

        # proxy to add a new content_id if empty on creation
        def create_with_i18n_fields
          initialize_i18n_fields
          create_without_i18n_fields
        end

        def initialize_i18n_fields
          if self.class.is_translatable?
            # we do this even if there is not currently any tr. attribute,
            # as long as is a translatable model
            unless self.content_id
              self.content_id = self.class.connection.next_val_sequence("#{self.class.table_name}_$_content_id")
            end
            unless self.locale
              self.locale = Locale.current
            end
          end
        end

        # When cloning a object do not copy the content_id
        def clone_with_i18n_fields_ignore
          clone = clone_without_i18n_fields_ignore
          clone.content_id = nil if self.class.is_translatable?
          clone
        end

        def assign_attributes_with_i18n_fields(new_attributes, options = {})
          if self.class.is_translatable?
            fields_to_populate = %w{locale content_id}
            attributes_to_apply = new_attributes.select { |key, value| fields_to_populate.include?(key.to_s) }
            attributes_to_apply.each do |key, value|
              write_attribute key.to_sym, value
            end
          end
          send("assign_attributes_without_i18n_fields", new_attributes, options)
        end

        # Whenever we update existing content or create a translation, the expected behaviour is the following
        # - The translatable fields will be updated just for the current instance
        # - Fields not defined as translatable will need to be updated for every instance that shares the same content_id
        def create_with_translatable
          create_without_translatable.tap do |saved|
            update_translations if saved
          end
        end

        def update_with_translatable
          update_without_translatable.tap do |saved|
            update_translations if saved
          end
        end

        def update_translations
          if self.class.is_translatable? && !@stop_translatable_propagation
            # prepare "self" to be the relations model for its translations
            self.prepare_for_shared_translations
            # Update the translations
            self.translations.each do |translation|
              translation.without_updating_translations do
                translation.update_attributes untranslatable_attributes, :without_protection => true
                translation.copy_translatable_shared_relations_from self
              end
            end
          end
        end

        def untranslatable_attributes_names
          translatable_attributes = (self.class.translatable_attributes || []) +
            (self.class.instance_variable_get('@global_translatable_attributes') || []) +
            (self.class.reflections.select do |name, ref|
                ref.macro != :belongs_to ||
                !ref.is_translation_shared? ||
                ((model = [send(name)].first) && model.class.is_translatable?)
            end.map{|name, ref| ref.association_foreign_key})
          attribute_names - translatable_attributes.map{|attr| attr.to_s}
        end

        def untranslatable_attributes
          attrs = {}
          (untranslatable_attributes_names + ['content_id'] - ['id']).each do |name|
            attrs[name] = clone_attribute_value(:read_attribute, name)
          end
          attrs
        end

        # Returns true if the primary_key for +reflection+ has been changed, and it was not nil before
        def has_updated_existing_primary_key reflection
          send("#{reflection.association_foreign_key}_changed?") && send("#{reflection.association_foreign_key}_was")
        end

        def attributes_except_unique_for_translation
          attributes.reject{|attr, value| [:id, :locale].include?(attr.to_sym)}
        end

        # Used to execute a block disabling automatic translation update for this instance
        def without_updating_translations
          previous_value = @stop_translatable_propagation
          @stop_translatable_propagation = true
          begin
            yield
          ensure
            @stop_translatable_propagation = previous_value
          end
        end

        # Execute a block without being affected by any possible current locale
        def without_current_locale loc = nil
          begin
            @current_locale, Locale.current = Locale.current, loc if Locale.current
            yield
          ensure
            Locale.current = @current_locale
          end
        end

      end

    end
  end
end
