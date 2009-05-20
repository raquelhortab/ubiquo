module UbiquoAuthentication
  # Helper class used from rake ubiquo:create_user to create ubiquo users from the console
  class UbiquoUserConsoleCreator
    
    # Creates a new ubiquo user accepts required fields as parameters.
    def self.create!(options = {})
      old_locale = I18n.locale
      I18n.locale = :en
      user = UbiquoUser.create(
               :login                 => options[:login], 
               :password              => options[:password], 
               :password_confirmation => options[:password_confirmation],
               :email                 => options[:email],
               :name                  => options[:name],
               :surname               => options[:surname],
               :is_active             => options[:is_active],
               :is_admin              => options[:is_admin],
               :is_superadmin         => options[:is_superadmin])
      I18n.locale = old_locale
      user
    end
    
  end
end
