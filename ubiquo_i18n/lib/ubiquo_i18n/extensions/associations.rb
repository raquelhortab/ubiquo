module UbiquoI18n
  module Extensions
    module Associations

      def self.append_features(base)
        base.send :include, InstanceMethods
        base.alias_method_chain :build, :shared_translations
#        base.alias_method_chain :delete_all_has_many_dependencies, :shared_translations
#        base.alias_method_chain :nullify_has_many_dependencies, :shared_translations
      end

      module InstanceMethods
        def build_with_shared_translations
          build_without_shared_translations.tap do |reflection|
            model.process_translation_shared reflection
          end
        end

#        def delete_all_has_many_dependencies_with_shared_translations(record, reflection_name, association_class, dependent_conditions)
#          reflections[reflection_name].propagate_dependent_option_with_shared_translations(record) do
#            delete_all_has_many_dependencies_without_shared_translations(record, reflection_name, association_class, dependent_conditions)
#          end
#        end
#
#        def nullify_has_many_dependencies_with_shared_translations(record, reflection_name, association_class, primary_key_name, dependent_conditions)
#          reflections[reflection_name].propagate_dependent_option_with_shared_translations(record) do
#            nullify_has_many_dependencies_without_shared_translations(record, reflection_name, association_class, primary_key_name, dependent_conditions)
#          end
#        end
      end
    end
  end
end