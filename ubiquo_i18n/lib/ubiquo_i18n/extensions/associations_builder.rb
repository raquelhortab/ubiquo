module UbiquoI18n
  module Extensions
    module AssociationsBuilder

      def self.append_features(base)
        base::Association.send :include, Association
        base::CollectionAssociation.send :include, CollectionAssociation
        base::HasMany.send :include, HasMany
      end

      # This module adds the parsing of the :translation_shared option in association definitions
      module Association
        def self.included(base)
          base.alias_method_chain :build, :shared_translations
        end

        def build_with_shared_translations
          build_without_shared_translations.tap do |reflection|
            model.process_translation_shared reflection
          end
        end
      end

      # On collection associations, when deleting an associated record, we should
      # propagate this change to translations. We add an after_remove callback to do so.
      module CollectionAssociation

        def self.included klass
          klass.alias_method_chain :build, :shared_translations_propagation
        end

        def build_with_shared_translations_propagation
          build_without_shared_translations_propagation.tap do |reflection|
            callbacks = model.send("after_remove_for_#{reflection.name}")
            callback_name = :"sync_deletion_of_#{reflection.name}_elements_across_translations"
            callbacks << callback_name

            reflection.active_record.send :define_method, callback_name do |removed|
              self.class.translating_relations do
                if reflection.is_translation_shared?

                  # Tell to the record translations that this element has been removed
                  translations.each do |translation|
                    to_remove = removed.class.is_translatable? ? removed.with_translations : removed
                    translation.send(reflection.name).delete to_remove
                  end if self.class.is_translatable?

                  # The translations of the removed item have to be also removed
                  # from this record's association
                  if removed.class.is_translatable?
                    send(reflection.name).delete removed.translations
                  end
                end
              end
            end
          end
        end

      end

      # On has_manys we intercept the :dependent policies to see if they really should be applied
      module HasMany

        def self.included klass
          klass.alias_method_chain :build, :shared_translations_dependency
        end

        def build_with_shared_translations_dependency
          build_without_shared_translations_dependency.tap do |reflection|

            # define the replacement method to be used
            if options[:dependent]
              name = dependency_method_name
              mixin.redefine_method "#{name}_with_shared_translations" do

                # we basically use a wrapper that will yield depending on some logic
                reflection.propagate_dependent_option_with_shared_translations(self) do
                  send("#{name}_without_shared_translations")
                end

              end

              # ... and hook it
              mixin.send :alias_method_chain, name, :shared_translations
            end
          end
        end

      end
    end
  end
end