class UbiquoUsersNotifier < ActionMailer::Base
  default :from => Ubiquo::Settings.get(:notifier_email_from)
  #Send a mail to the desired user with a new generated password.
  #It's necesary to specify the host because mailer can't know in what host are running rails
  def forgot_password(user, host)
    @user = user
    @locale = user.locale.blank? ? Ubiquo.default_locale : user.locale
    @host = host
    subject = I18n.t('ubiquo.auth.new_pass_generated', 
      :app_title => Ubiquo::Settings.get(:app_title), 
      :locale => locale)
    mail(:to => @user.email, :subject => subject)
  end
  
  #Send a mail to the desired user with the information of their new account.
  #It's necesary to specify the host because mailer can't know in what host are running rails
  def confirm_creation(user, welcome_message, host)
    @user = user
    @locale = user.locale.blank? ? Ubiquo.default_locale : user.locale
    @host = host
    @welcome_message = welcome_message
    subject = I18n.t('ubiquo.auth.new_user_created',
      :app_title => Ubiquo::Settings.get(:app_title),
      :locale => locale)
    mail(:to => @user.email, :subject => subject)
  end

end
