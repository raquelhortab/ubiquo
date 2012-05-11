module UbiquoI18n
  module Extensions

    # This module extends the collection association assignation to do
    # the expected job with initialized_shared_translations.
    # We have to detect this special case to avoid propagation of this replacement
    # to other translations, since if the association is not loaded, will look
    # like it's a fair case do load the translation contents. And if these are loaded,
    # then will be replaced (and perhaps this means being deleted)
    module CollectionAssociation

      def self.included klass
        klass.alias_method_chain :replace, :shared_translations
      end

      def replace_with_shared_translations(*args)
        # If it's the case we are looking for, just say that the target is loaded.
        # The real contents do not matter as they were going to be replaced,
        # and we precisely want to avoid that.
        loaded! if reflection.can_be_initialized?(owner)
        replace_without_shared_translations(*args)
      end
    end
  end
end