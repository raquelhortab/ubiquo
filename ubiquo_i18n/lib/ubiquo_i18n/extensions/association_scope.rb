module UbiquoI18n
  module Extensions
    # This module extends a very concrete part of the scope construction in queries.
    # Unfortunately this part is deep inside a large method, and there is no neat
    # way to do it, so I ended up replacing the whole add_constraints method, which
    # is a not a good solution but the most reasonable as I see it.
    # It is expected that a future refactoring of the rails method will allow a better
    # way to extend this.
    module AssociationScope

      def self.included klass
        klass.alias_method_chain :add_constraints, :shared_translations
      end


      def add_constraints_with_shared_translations(scope)
        tables = construct_tables

        chain.each_with_index do |reflection, i|
          table, foreign_table = tables.shift, tables.first

          if reflection.source_macro == :has_and_belongs_to_many
            join_table = tables.shift

            scope = scope.joins(join(
              join_table,
              table[reflection.association_primary_key].
                eq(join_table[reflection.association_foreign_key])
            ))

            table, foreign_table = join_table, tables.first
          end

          if reflection.source_macro == :belongs_to
            if reflection.options[:polymorphic]
              key = reflection.association_primary_key(klass)
            else
              key = reflection.association_primary_key
            end

            foreign_key = reflection.foreign_key
          else
            key         = reflection.foreign_key
            foreign_key = reflection.active_record_primary_key
          end

          conditions = self.conditions[i]

          if reflection == chain.last
            # original code
            # scope = scope.where(table[key].eq(owner[foreign_key]))
            ### beginif i18n
            if applicable_translation_shared? reflection
              origin = owner.class.is_translatable? ? owner.with_translations : [owner]
              scope = scope.where(table[key].in(origin.map(&foreign_key.to_sym))).localized(:mode => :mixed)
            else
              scope = scope.where(table[key].eq(owner[foreign_key]))
            end
            #### endif i18n
            if reflection.type
              scope = scope.where(table[reflection.type].eq(owner.class.base_class.name))
            end

            conditions.each do |condition|
              if options[:through] && condition.is_a?(Hash)
                condition = { table.name => condition }
              end

              scope = scope.where(interpolate(condition))
            end
          else
            constraint = table[key].eq(foreign_table[foreign_key])

            if reflection.type
              type = chain[i + 1].klass.base_class.name
              constraint = constraint.and(table[reflection.type].eq(type))
            end

            scope = scope.joins(join(foreign_table, constraint))

            unless conditions.empty?
              scope = scope.where(sanitize(conditions, table))
            end
          end
        end

        scope
      end

      # If we don't have a current locale there is nothing we can do to share.
      # Also, if the reflection is not marked as shared we should do nothing.
      # Finally, belongs_to works differently, as it's based in an actual field
      def applicable_translation_shared? reflection
        Locale.current && reflection.is_translation_shared?(owner) &&
          (reflection.macro != :belongs_to || !owner.has_updated_existing_primary_key(reflection))
      end

    end
  end
end
