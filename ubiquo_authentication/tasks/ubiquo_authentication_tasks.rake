namespace :ubiquo do
  desc "Creates a new ubiquo user"
  task :create_user => :environment do
    begin
      gem 'highline'
    rescue Gem::LoadError => load_error
      $stderr.puts "ERROR. You should install the highline gem to use this task: sudo gem install highline"
      exit 1
    end
    require 'highline/import'
    login                 = ask("Enter user login: ")
    password              = ask("Enter user password: ") { |q| q.echo = "*" }
    password_confirmation = ask("Enter password again: ") { |q| q.echo = "*" }
    is_active             = agree("Should this user be active? ")
    is_admin              = agree("Should this user have admin privileges? ")
    is_superadmin         = agree("Should this user have superadmin privileges? ")
    UbiquoUser.create!(:login                 => login, 
                       :password              => password, 
                       :password_confirmation => password_confirmation,
                       :is_active             => is_active,
                       :is_admin              => is_admin,
                       :is_superadmin         => is_superadmin)
  end
end
