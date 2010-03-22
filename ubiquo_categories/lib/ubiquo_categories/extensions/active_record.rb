module UbiquoCategories
  module Extensions
    module ActiveRecord

      def self.append_features(base)
        super
        base.extend(ClassMethods)
        base.send :include, InstanceMethods
      end
      
      module ClassMethods

        DEFAULT_CATEGORIZED_OPTIONS = {
          :size => 1,
          :separator => '##'
        }

        # Class method for ActiveRecord that states that a attribute is categorized
        #
        # Example:
        #
        #   categorized_with :city
        # 
        # possible options:
        #   :from => CategorySet key(s) where this attribute should feed from.
        #            If it's not provided, will pluralize the attribute name and
        #            use it as the key.
        #   :size => the max number of categories that can be selected.
        #            Can be an integer or :many if there is no limit. Default: 1
        #   :separator => The char(s) that delimite the different categories when
        #                 creating them from a string. Defaults to double hash (##)
        #
        #                  

        def categorized_with(field, options = {})
          options.reverse_merge!(DEFAULT_CATEGORIZED_OPTIONS)

          self.has_many(:category_relations, {
              :as => :related_object,
              :class_name => "::CategoryRelation",
              :dependent => :destroy,
              :order => "category_relations.position ASC"
          }) unless self.respond_to?(:category_relations)

          association_name = field.to_s.pluralize

          proc = Proc.new do

            define_method "<<" do |categories|
              set = CategorySet.find_by_key association_name
              raise UbiquoCategories::SetNotFoundError unless set

              [categories].flatten.each do |category|
                raise UbiquoCategories::LimitError if is_full?
                
                case category
                when String
                  unless set.categories.map(&:name).include? category
                    set.categories << category
                  end
                when Category
                  unless set.categories.include? category
                    set.categories << category
                  end
                end
                @reflection.through_reflection.klass.create(
                  :attr_name => association_name,
                  :related_object => proxy_owner,
                  :category => set.categories.select{|c| c.name == category.to_s}.first
                )
              end
            end

            if options[:size] == 1
              # Returns directly the instance if only one category is allowed
              def find_target
                super.first
              end
            end
            
            define_method('is_full?') do
              return false if options[:size].to_sym == :many
              self.size >= options[:size]
            end
          end

          self.has_many(association_name, {
              :through => :category_relations,
              :class_name => "::Category",
              :source => :category,
              :conditions => ["category_relations.attr_name = ?", association_name],
              :order => "category_relations.position ASC"
            },&proc)

          define_method "#{association_name}=" do |categories|
            categories = categories.split(options[:separator]) if categories.is_a? String
            self.send(association_name) << categories
          end

          if field != association_name
            alias_method field, association_name
            alias_method "#{field}=", "#{association_name}="
          end
          
        end

      end
      
      module InstanceMethods
        
        def self.included(klass)
        end

      end

    end
  end
end
