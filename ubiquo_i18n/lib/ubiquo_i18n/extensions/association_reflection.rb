module UbiquoI18n
  module Extensions
    module AssociationReflection

      def self.append_features(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        # Returns true if the reflection's destiny is translatable, or if to reach
        # it we have an intermediate table that it's translatable.
        def is_translatable?
          klass.is_translatable? || has_many_through_translatable?
        end

        # Returns true if the reflection is a has_many to an untranslatable model
        def has_many_through_translatable?
          options[:through] && through_reflection.klass.is_translatable?
        end

        # Returns true if +record+ has the reflection contents shared with its translations
        # If there is no +record+, returns the general use case
        def is_translation_shared?(record = nil)
          options[:translation_shared] || can_be_initialized?(record)
        end

        def can_be_initialized?(record, ignore_association_loading = false)
          if is_translation_shared_on_initialize? && record && record.new_record?
            ignore_association_loading || !record.association(name).loaded?
          end
        end

        def is_translation_shared_on_initialize?
          options[:translation_shared_on_new]
        end

        # Marks this reflection as :translation_shared if +value+ says so.
        # +options+ can be one of:
        #   :only_new => :translation_shared +value+ will only be applied for new records
        def mark_as_translation_shared(value, options = {})
          if options[:only_new]
            self.options[:translation_shared_on_new] = value
          else
            self.options[:translation_shared] = value
          end
        end

        # Returns true if the reflection can run its course with the usual
        # :dependent behaviour
        def should_propagate_dependent_option? record
          # When we really want to delete associated records? when these are
          # not being used by any translations. This means that either +record+
          # has no translations, or that its translations use a different set of records
          all_records = record.translations.map do |translation|
            translation.without_current_locale(translation.locale) do
              translation.send(name).to_a
            end
          end.flatten
          (all_records & record.send(name)).empty?
        end

        # If the associated records are shared with other translations, the
        # given block is not executed (associated records are not deleted),
        # but as +record+ is deleted, any related foreign key is updated to
        # another translation.
        def propagate_dependent_option_with_shared_translations record
          # if this model is not translatable, act normally
          yield && return unless record.class.is_translatable?

          if should_propagate_dependent_option? record
            klass.translating_relations do
              yield
            end
          end
          update_foreign_keys_to_point_another_translation record if record.translations.exists?
        end

        # Any associated record pointing to +record+ will be updated to another
        # translation of +record+ (it is assumed it has translations)
        def update_foreign_keys_to_point_another_translation record
          record.without_current_locale do
            associated = record.send(name)
            associated.update_all({foreign_key => record.translations.first.id})
          end
        end
      end
    end
  end
end
