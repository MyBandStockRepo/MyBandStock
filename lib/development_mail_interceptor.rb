# lib/development_mail_interceptor.rb
class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "#{message.to} #{message.subject}"
    
    unless EMAIL_INTERCEPTOR_ADDRESS.nil?
			message.to = "#{EMAIL_INTERCEPTOR_ADDRESS}"
		end
  end
end