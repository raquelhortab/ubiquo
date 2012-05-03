module UbiquoI18n
  module Extensions
    module Relation

      # Applies the locale filter if needed, then performs the normal find method

      def self.included(klass)

        klass.class_eval do
          alias_method_chain :to_a, :locale_filter
          alias_method_chain :perform_calculation, :locale_filter
          attr_accessor :locale_values
          klass::MULTI_VALUE_METHODS << :locale
        end
      end

      def perform_calculation_with_locale_filter(operation, column_name, options = {})
        apply_locale_filter if klass.is_translatable?
        perform_calculation_without_locale_filter(operation, column_name, options = {})
      end

      def to_a_with_locale_filter
        apply_locale_filter if klass.is_translatable?
        to_a_without_locale_filter
      end

      # usage:
      # find all content in any locale: Model.locale(:all)
      # find Spanish content: Model.locale('es')
      # find Spanish or English content. If Spanish and English exists, gets the Spanish version. Model.locale('es', 'en')
      # find all content in Spanish or any other locale if Spanish dosn't exist: Model.locale('es', :all)
      # find all content in any locale: Model.locale(:all)
      #
      def locale(*locales)
        return self if locales.blank?

        relation = clone
        relation.locale_values = locales
        relation
      end

        # This method is the one that actually applies the locale filter
        # This means that if you use .locale(..), you'll end up here,
        # when the results are actually delivered (not in call time)
        # Returns a hash with the resulting +options+ with the applied filter
        def apply_locale_filter
          locales, self.locale_values = self.locale_values, nil
          if locales.present?
            # build locale restrictions
            locale_options = locales.extract_options!
            all_locales = locales.delete(:all)

            # add untranslatable instances if necessary
            locales << :any unless all_locales || locales.size == 0

            if all_locales
              locale_conditions = ""
            else
              locale_conditions = ["#{self.table_name}.locale in (?)", locales.map(&:to_s)]
              # act like a normal condition when we are just filtering a locale
              if locales.size == 2 && locales.include?(:any) && locale_options[:strict]
                self.where_values += build_where(locale_conditions)
                reset && return
              end
            end
            # locale preference order
            tbl = self.table_name
            locales_string = locales.size > 0 ? (["#{tbl}.locale != ?"]*(locales.size)).join(", ") : nil
            locale_array = ["#{tbl}.content_id", locales_string].compact.join(", ")
            locale_order = "#{@klass.send(:sanitize_sql, ["#{locale_array}", *locales.map(&:to_s)])}"

            join_dependency = construct_join_dependency_for_association_find
            relation = construct_relation_for_association_find(join_dependency)
            joins_sql = relation.arel.join_sql
#            require 'ruby-debug'; debugger if defined? AAA
            conditions_sql = arel.where_sql || ''
            conditions_sql.sub!('WHERE', '')

            conditions_tables = tables_in_string(conditions_sql)
            references_other_tables = conditions_tables.size > 1 || conditions_tables.first != self.table_name
            if references_other_tables
              mixed_conditions = merge_conditions(*other_table_conditions(where_values))
              own_conditions = merge_conditions(*same_table_conditions(where_values))
            end

            # now construct the subquery
            if locale_conditions.present?
              sql_locale_conditions = Arel::SqlLiteral.new("(#{@klass.send(:sanitize_sql, locale_conditions)})")
            end

            from_and_joins = "FROM #{tbl} " + joins_sql.to_s

            adapters_with_custom_sql = %w{postgresql mysql mysql2}
            current_adapter = connection.adapter_name.downcase
            if adapters_with_custom_sql.include?(current_adapter)

              # Certain adapters support custom features that allow the locale
              # filter to do its job in a single sql. We use them for efficiency
              # In these cases, the subquery that will be build must respect
              # includes, joins and conditions from the original query
              # Note: all this is crying for a refactoring


              subfilter = case locale_options[:mode]
              when :strict
                all_conditions = merge_conditions(conditions_sql, sql_locale_conditions)
                from_and_joins + (all_conditions.present? ? "WHERE #{all_conditions}" : '')
              when :mixed
                content_id_query = from_and_joins
                content_id_query << " WHERE #{conditions_sql} " if conditions_sql.present?
                id_extra_cond = sql_locale_conditions.present? ? " #{sql_locale_conditions} AND " : ''

                # these are already factored in the new conditions
                self.where_values = self.joins_values = []
                "FROM #{tbl} WHERE #{id_extra_cond} #{tbl}.content_id IN ("+
                    "SELECT #{tbl}.content_id #{content_id_query})"
              else
                # Default. Only search for matches in translations in associations
                if references_other_tables
                  content_id_query = from_and_joins
                  content_id_query << " WHERE #{mixed_conditions} " unless mixed_conditions.blank?
                  id_extra_cond = merge_conditions(own_conditions, sql_locale_conditions)
                  id_extra_cond += ' AND' if id_extra_cond.present?

                  # these are already factored in the new conditions
                  self.where_values = self.joins_values = []
                  "FROM #{tbl} WHERE #{id_extra_cond} #{tbl}.content_id IN ("+
                       "SELECT #{tbl}.content_id #{content_id_query})"
                else
                  # No associations involved. Same as :strict. Needs a refactor!
                  all_conditions = merge_conditions(conditions_sql, sql_locale_conditions)
                  from_and_joins + (all_conditions.present? ? " WHERE #{all_conditions} " : '')
                end
              end

              locale_filter = case current_adapter
              when "postgresql"
                # use a subquery with DISTINCT ON, more efficient, but currently
                # only supported by Postgres

                "#{tbl}.id IN (" +
                    "SELECT DISTINCT ON (#{tbl}.content_id) #{tbl}.id " + subfilter +
                    "ORDER BY #{locale_order})"

              when "mysql", "mysql2"
                # it's a "within-group aggregates" problem. We need to order before grouping.
                # This subquery is O(N * log N), while a correlated subquery would be O(N^2)

                "#{tbl}.id IN (" +
                    "SELECT id FROM ( SELECT #{tbl}.id, #{tbl}.content_id " + subfilter +
                    "ORDER BY #{locale_order}) AS lpref " +
                    "GROUP BY content_id)"

              end

              # finally, merge the created subquery into the current conditions
              self.where_values += [locale_filter]
              reset

            else
              # For the other adapters, the strategy is to do two subqueries.
              # This can be problematic for generic queries since we have to
              # suppress the paginator scope to guarantee the correctness (#254)

                conditions_for_id_query = case locale_options[:mode]
                when :strict
                    merge_conditions(conditions_sql, sql_locale_conditions)

                when :mixed
                      original_query = from_and_joins
                      joins_sql = nil # already applied
                      (original_query << " WHERE #{conditions_sql} ") if conditions_sql.present?
                      extra_cond = sql_locale_conditions.present? ? "#{sql_locale_conditions} AND" : ''
                      "#{extra_cond} #{tbl}.content_id IN ("+
                          "SELECT #{tbl}.content_id #{original_query})"
                else
                  # Default. Only search for matches in translations in associations
                  if references_other_tables
                    content_id_query = from_and_joins
                    content_id_query << " WHERE #{mixed_conditions} " unless mixed_conditions.blank?
                    joins_sql = nil # already applied
                    id_extra_cond = merge_conditions(own_conditions, sql_locale_conditions)
                    id_extra_cond += ' AND' if id_extra_cond.present?
                    "#{id_extra_cond} #{tbl}.content_id IN ("+
                        "SELECT #{tbl}.content_id #{content_id_query})"
                  else
                    # No associations involved. Same as :strict
                    merge_conditions(conditions_sql, sql_locale_conditions)
                  end
                end


              # these are already factored in the new conditions
              self.where_values = self.joins_values = []

              candidate_ids = unscoped.all(
                :select => "#{tbl}.id, #{tbl}.content_id ",
                :conditions => conditions_for_id_query,
                :order => locale_order,
                :joins => joins_sql
              )

              # get only one ID per content_id
              content_ids = {}
              ids = candidate_ids.select{ |id| content_ids[id.content_id].nil? ? content_ids[id.content_id] = id : false }.map{|id| id.id.to_i}

              self.where_values = build_where({:id => ids})
              reset
            end
          end
        end

        def merge_conditions *args
          conditions = args.reject(&:blank?).join(') AND (')
          return '' if conditions.blank?
          Arel::SqlLiteral.new("(#{@klass.send(:sanitize_sql, conditions)})")
        end

        # returns an array with the sql conditions that refer to other trables
        def other_table_conditions(conditions)
          normalized_conditions(conditions) - same_table_conditions(conditions)
        end

        # returns an array with the sql conditions that refer to this model table
        def same_table_conditions(conditions)
          normalized_conditions(conditions).select{ |cond| cond =~ /\b#{table_name}.?\./ }
        end

        # returns an array of all the applicable sql conditions
        def normalized_conditions(conditions)
          conditions.map do |condition|
            sql_condition = condition.is_a?(Arel::Nodes::Equality) ? condition.to_sql : condition
            @klass.send(:sanitize_sql, sql_condition)
          end.reject(&:blank?)
        end
    end
  end
end