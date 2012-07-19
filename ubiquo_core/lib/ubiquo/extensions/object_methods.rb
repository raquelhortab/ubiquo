module Ubiquo
  module Extensions
    # This module breaks the convention, should be called Object.
    # It is intentional:  there was a very subtle problem with Rails reloader,
    # where everything seemed to work, but for some reason naming this module
    # Object didn't define Ubiquo::Extensions::Object, but Ubiquo::Extensions,
    # and therefore this constant was added to the autoloaded_constants array,
    # where it shouldn't be as the extensions should be only added once.
    # Well, in short, please don't name any module Object, or trouble will come.
    module ObjectMethods
      def to_bool
        ![false, 'false', '0', 0, 'f', nil].include?(self.respond_to?(:downcase) ? self.downcase : self)
      end
    end
  end
end
