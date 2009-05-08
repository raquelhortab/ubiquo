module UbiquoAuthentication
  module Extensions
    module Controller
      def self.included(klass)
        klass.before_filter :set_ubiquo_locale
      end
      def set_ubiquo_locale
        return true unless logged_in?
        user_locale = current_ubiquo_user.locale
        user_locale = nil if user_locale.blank?
        I18n.locale = user_locale || Ubiquo.default_locale
        true
      end
    end
  end
end
