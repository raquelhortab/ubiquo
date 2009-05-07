class UbiquoUsersNotifier < ActionMailer::Base
  

  def forgot_password(user, host)
    subject '[%s] Nueva contraseña generada' % Ubiquo::Config.get(:app_title)
    recipients user.email
    from Ubiquo::Config.get(:app_title) + "<railsmail@gnuine.com>"
    @template += "_es"
    body :user => user, :host => host
  end

  def confirm_creation(user, welcome_message, host)
    subject '[%s] Nuevo usuario creado' % Ubiquo::Config.get(:app_title)
    recipients user.email
    from Ubiquo::Config.get(:app_title) + "<railsmail@gnuine.com>"
    @template += "_es"
    
    body :user => user, :host => host, :welcome_message => welcome_message
  end

end
