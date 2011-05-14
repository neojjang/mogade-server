class Notifier

  def self.welcome(developer, url)
    message = TMail::Mail.new
    message.from = Settings.admin_email
    message.to = developer.email
    message.subject = 'Mogade Account Registration'
    message.content_type = 'text/html'
    message.body = append_environment_warning + <<-eos
      <p>Hi #{developer.username},</p>
      <p>You recently registered for an account at mogade.com. To complete the process, please click on the following link:</p>
      <p><a href="#{url}">#{url}</a></p>
      <p>Sincerely,<br />Mogade</p>
    eos
    message.tag = 'welcome'
    Postmark.send_through_postmark(message)
   end
   
   def self.send_password(developer, url)
     message = TMail::Mail.new
     message.from = Settings.admin_email
     message.to = developer.email
     message.subject =  'Mogade Password Reset'
     message.content_type = 'text/html'
     message.body = append_environment_warning + <<-eos
       <p>Hi #{developer.username},</p>
       <p>A request was recently made to reset your password. If you did't make this request, or if you found your original password, you can safely ignore this message:</p>
       <p>Otherwise, to reset your password, click on the following link:</p>
       <p><a href="#{url}">#{url}</a></p>
       <p>The above link will expire in 24 hours</p>
       <p>Sincerely,<br />Mogade</p>
     eos
     message.tag = 'password'
     Postmark.send_through_postmark(message)
   end
   
   private 
   def self.append_environment_warning
     return '' if Rails.env == 'production'     
     "<p>NOT PRODUCTION</p><p>This email was sent from a testing environment (#{Rails.env})</p>"
   end
end
