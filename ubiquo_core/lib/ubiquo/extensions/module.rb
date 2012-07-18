module Ubiquo
  module Extensions
    module Module
      def self.included klass
        klass.class_eval do

          # Avoids the problem that happens when you double-aliase the same method,
          # which for example can happen if you reload extensions. In this case
          # you'll get a nice infinite recursion and usually with no hints.
          # This halts these situations.
          def alias_method_chain_with_recursion_control target, feature
            aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ''), $1
            yield(aliased_target, punctuation) if block_given?
            without_method = "#{aliased_target}_without_#{feature}#{punctuation}"

            # Without_method shouldn't exist, it's a method to be created
            # Can there be a valid reason to aliase it? Maybe, but then you're using
            # alias_method_chain to achieve a collateral effect, shouldn't you simply
            # use alias_method?
            unless (instance_methods + private_methods).include?(without_method.to_sym)
              alias_method_chain_without_recursion_control target, feature
            end
          end

          alias_method_chain :alias_method_chain, :recursion_control

        end
      end
    end
  end
end
