module UbiquoCategories
  module Extensions
    module ActiveRecord

      def self.append_features(base)
        super
        base.extend(ClassMethods)
        base.send :include, InstanceMethods
      end
      
      module ClassMethods
        
        # Class method for ActiveRecord that states that a attribute is categorized
        #
        # Example:
        #
        #   categorized_with :city
        # 
        # possible options:
        #   :from => CategorySet key(s) where this attribute should feed from
        #                  
        #                  
        
        def categorized_with(attr, options = {})
        end

      end
      
      module InstanceMethods
        
        def self.included(klass)
        end

      end

    end
  end
end
