module UbiquoAccessControl::Extensions::UbiquoUser

  def self.included ubiquo_user_klass
    ubiquo_user_klass.class_eval do
      has_many :ubiquo_user_roles
      has_many :roles, :through => :ubiquo_user_roles

      # Returns true if this ubiquo_user has specified permission
      def has_permission?(permission)
        return true if self.is_admin?
        permission = Permission.gfind(permission)
        return false unless permission
        self.roles.each do |role|
          return true if role.permissions.map(&:key).include?(permission.key)
        end
        false
      end

    end
  end

end