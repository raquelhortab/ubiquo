module UbiquoI18n
  module Extensions
    module Association

      def self.included klass
        klass.alias_method_chain :stale_state, :locale
        klass.alias_method_chain :find_target?, :shared_translations
      end

      # Returns the association target without the effect of this extension
      def without_shared_translations
        owner.without_current_locale { reload }
        reflection.collection? ? proxy : self
      end

      def stale_state_with_locale
        [stale_state_without_locale, Locale.current]
      end

      def find_target_with_shared_translations?
        find_target_without_shared_translations? ||
          (!loaded? && klass && owner.new_record? && reflection.is_translation_shared?(owner))
      end

    end
  end
end
