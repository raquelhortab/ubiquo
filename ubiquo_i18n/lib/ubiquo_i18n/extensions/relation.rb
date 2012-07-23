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
      def locale(*opts)
        return self if opts.blank?

        relation = clone
        relation.locale_values = opts
        relation
      end

      # Using localized is like using locale(current_locale, :all),
      # but automatically using the possibly defined locale fallback list
      # if the Locale.use_fallbacks flag is enabled
      def localized(options = {})
        locales = Locale.use_fallbacks ? Locale.fallbacks(Locale.current) : Locale.current
        locale(*[locales, options].flatten)
      end

      # This method is the one that actually applies the locale filter
      # This means that if you use .locale(..), you'll end up here,
      # when the results are actually delivered (not in call time)
      # This method modifies the current scope accordingly to the locales that
      # you are requesting, and according to the locale mode, which determines who
      # needs to fulfill the current conditions:
      #   :default => own table conditions should be fulfilled by itself,
      #               other table conditions can be fulfilled only by translations
      #               (this is the default because this is how translation_shared works)
      #
      #   :mixed => a record should be included if it, or a translation of it,
      #             fulfills all the conditions
      #
      #   :strict => a record should only be included in the results if
      #              it fulfills all the conditions by itself
      #              (not one of their translations)
      def apply_locale_filter
        locales, self.locale_values = self.locale_values, nil
        return unless locales.present?

        # build locale restrictions
        locale_options = locales.extract_options!
        all_locales = locales.delete(:all)

        # untranslatable instances (locale = 'any') always are taken into account,
        # but it's only necessary to include them explicitly when we are not using :all
        locales << :any unless all_locales

        # if :all is not used, then we should strictly only have results from
        # the set of given locales. With :all, it's all a matter of order
        if !all_locales
          locale_conditions = ["#{self.table_name}.locale in (?)", locales.map(&:to_s)]
          sql_locale_conditions = Arel::SqlLiteral.new("(#{@klass.send(:sanitize_sql, locale_conditions)})")
        end

        joins_sql, conditions_sql = joins_and_conditions_from_current_scope
        locale_mode = locale_options[:mode] || determine_locale_mode(conditions_sql)

        # Act like a normal condition when we are just filtering a locale
        # (.locale('en')) and we are in strict mode.
        # Note that :any has been added, that's why locales.size will be == 2
        if !all_locales && locales.size == 2 && locale_mode == :strict
          self.where_values += build_where(locale_conditions)
          reset && return
        end

        # With all this data, now build and apply the sql
        build_sql_locale_subfilter(locale_mode, locales, conditions_sql, sql_locale_conditions, joins_sql)
      end

      # Constructs and applies the locale filtering subquery, which intuitively is:
      # "Select all the items having a content_id of an item fulfilling the
      #  conditions, and then sort them by locale preference, and choose
      #  only the first"
      def build_sql_locale_subfilter(locale_mode, locales, conditions_sql, sql_locale_conditions, joins_sql)
        locale_order = build_locale_preference_order_sql(locales)
        subfilter = locale_subfilter_sql(locale_mode, conditions_sql, sql_locale_conditions, joins_sql)

        # in non-strict modes, 3rd-table conditions and joins are already in +subfilter+
        if locale_mode != :strict
          joins_sql = nil
          self.where_values = self.joins_values = []
        end

        # Certain adapters support custom features that allow the locale
        # filter to do its job in a single sql. We use them for efficiency
        # In these cases, the subquery that will be build must respect
        # includes, joins and conditions from the original query
        adapters_with_custom_sql = %w{postgresql mysql mysql2}
        current_adapter = connection.adapter_name.downcase
        if adapters_with_custom_sql.include?(current_adapter)

          from_and_subfilter = "FROM #{table_name} #{joins_sql} WHERE" + subfilter
          locale_filter = case current_adapter
          when "postgresql"
            locale_subfilter_postgres_sql(from_and_subfilter, locale_order)

          when "mysql", "mysql2"
            locale_subfilter_mysql_sql(from_and_subfilter, locale_order)
          end

          # finally, merge the created subquery into the current conditions
          self.where_values += [locale_filter]
          reset

        else
          # adapters with limited sql features, like sqlite
          locale_subfilter_fallback(subfilter, locale_order, joins_sql)
        end
      end

      # use a subquery with DISTINCT ON, more efficient, but currently
      # only supported by Postgres
      def locale_subfilter_postgres_sql(from_and_subfilter, locale_order)
        tbl = self.table_name
        "#{tbl}.id IN (" +
          "SELECT DISTINCT ON (#{tbl}.content_id) #{tbl}.id #{from_and_subfilter}" +
          "ORDER BY #{locale_order})"
      end

      # it's a "within-group aggregates" problem. We need to order before grouping.
      # This subquery is O(N * log N), while a correlated subquery would be O(N^2)
      def locale_subfilter_mysql_sql(from_and_subfilter, locale_order)
        tbl = self.table_name
        "#{tbl}.id IN (" +
          "SELECT id FROM ( SELECT #{tbl}.id, #{tbl}.content_id #{from_and_subfilter}" +
          "ORDER BY #{locale_order}) AS lpref " +
          "GROUP BY content_id)"
      end

      # For the other adapters, the strategy is to do two subqueries.
      # This can be problematic for generic queries since we have to
      # suppress the paginator scope to guarantee the correctness (#254)
      def locale_subfilter_fallback(subfilter, locale_order, joins_sql)

        # these are already factored in the new conditions
        self.where_values = self.joins_values = []

        candidate_ids = unscoped.all(
          :select => "#{table_name}.id, #{table_name}.content_id ",
          :conditions => subfilter,
          :order => locale_order,
          :joins => joins_sql
        )

        # get only one ID per content_id
        content_ids = {}
        ids = candidate_ids.select do |id|
          content_ids[id.content_id].nil? ? content_ids[id.content_id] = id : false
        end.map{|id| id.id.to_i}

        self.where_values = build_where({:id => ids})
        reset
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

      # Get an array of [joins, conditions] sql strings given the current scope
      def joins_and_conditions_from_current_scope
        join_dependency = construct_join_dependency_for_association_find
        relation = construct_relation_for_association_find(join_dependency)
        joins_sql = relation.arel.join_sql
        conditions_sql = arel.where_sql || ''
        conditions_sql.sub!('WHERE', '')
        [joins_sql, conditions_sql]
      end

      # Returns true if the conditions sql contains conditions for other tables
      def references_other_tables?(conditions_sql)
        conditions_tables = tables_in_string(conditions_sql)
        conditions_tables.size > 1 || conditions_tables.first != self.table_name
      end

      def build_locale_preference_order_sql(locales)
        tbl = self.table_name
        locales_string = locales.size > 0 ? (["#{tbl}.locale != ?"]*(locales.size)).join(", ") : nil
        locale_array = ["#{tbl}.content_id", locales_string].compact.join(", ")
        "#{@klass.send(:sanitize_sql, ["#{locale_array}", *locales.map(&:to_s)])}"
      end

      # Returns the locale mode (:default or :strict) to use
      # given the conditions to be applied.
      # Basically, :strict is returned if there are no 3rd-table references,
      # because the generated sql is then simpler and more efficient
      def determine_locale_mode(conditions_sql)
        references_other_tables?(conditions_sql) ? :default : :strict
      end

      def locale_subfilter_sql(locale_mode, conditions_sql, sql_locale_conditions, joins_sql)
        send("locale_subfilter_sql_#{locale_mode}", conditions_sql, sql_locale_conditions, joins_sql)
      end

      # Returns the SQL for the locale subfilter for the :strict mode
      def locale_subfilter_sql_strict(conditions_sql, sql_locale_conditions, joins_sql)
        # everything is a single condition
        merge_conditions(conditions_sql, sql_locale_conditions)
      end

      # Returns the SQL for the locale subfilter for the :mixed mode
      def locale_subfilter_sql_mixed(conditions_sql, sql_locale_conditions, joins_sql)
        # all the conditions need to be placed in the content_id subfilter
        content_id_query = if conditions_sql.present?
          from_and_joins(joins_sql) + " WHERE #{conditions_sql}"
        else
          from_and_joins(joins_sql)
        end

        # the exception to this are the locale conditions,
        # which are applied as a top-level condition
        id_extra_cond = sql_locale_conditions.present? ? " #{sql_locale_conditions} AND " : ''

        "#{id_extra_cond} #{self.table_name}.content_id IN (" +
          "SELECT #{self.table_name}.content_id #{content_id_query})"
      end

      # Returns the SQL for the locale subfilter for the :default mode
      def locale_subfilter_sql_default(conditions_sql, sql_locale_conditions, joins_sql)
        # Default. Only search for matches in translations in associations
        # content_id_query is the query that returns electable instances,
        # regardless of its language.

        # When we are referencing other tables, we need to know which ones are
        # applied to our own table and which one are 3rd-table conditions
        if references_other_tables?(conditions_sql)
          mixed_conditions = merge_conditions(*other_table_conditions(where_values))
          own_conditions = merge_conditions(*same_table_conditions(where_values))
        end

        # any 3rd-reference condition is not strictly interpreted
        content_id_query = if mixed_conditions.present?
          from_and_joins(joins_sql) + " WHERE #{mixed_conditions}"
        else
          from_and_joins(joins_sql)
        end

        # but own-table conditions do must be fulfilled by the returned instance
        id_extra_cond = merge_conditions(own_conditions, sql_locale_conditions)
        # append AND to be correct sql
        id_extra_cond += ' AND' if id_extra_cond.present?

        "#{id_extra_cond} #{self.table_name}.content_id IN (" +
          "SELECT #{self.table_name}.content_id #{content_id_query})"
      end

      # Returns the given +joins_sql+ after a SQL from clause
      def from_and_joins joins_sql
        "FROM #{self.table_name} " + joins_sql.to_s
      end
    end
  end
end