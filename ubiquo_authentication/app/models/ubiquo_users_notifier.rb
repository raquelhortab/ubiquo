class UbiquoUsersNotifier < ActionMailer::Base
  
  #Send a mail to the desired user with a new generated password.
  #It's necesary to specify the host because mailer can't know in what host are running rails
  def forgot_password(user, host)
    subject '[%s] Nueva contraseña generada' % Ubiquo::Config.get(:app_title)
    recipients user.email
    from Ubiquo::Config.get(:app_title) + "<railsmail@gnuine.com>"
    @template += "_es"
    body :user => user, :host => host
  end
  
  #Send a mail to the desired user with the information of their new account.
  #It's necesary to specify the host because mailer can't know in what host are running rails
  def confirm_creation(user, welcome_message, host)
    subject '[%s] Nuevo usuario creado' % Ubiquo::Config.get(:app_title)
    recipients user.email
    from Ubiquo::Config.get(:app_title) + "<railsmail@gnuine.com>"
    @template += "_es"
    
    body :user => user, :host => host, :welcome_message => welcome_message
  end

end
