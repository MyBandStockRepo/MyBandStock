# lib/development_mail_interceptor.rb
class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "#{message.to} #{message.subject}"
    
    interceptor_address = (defined? EMAIL_INTERCEPTOR_ADDRESS) ? EMAIL_INTERCEPTOR_ADDRESS : nil
    
    unless interceptor_address.nil?
			message.to = "#{interceptor_address}"
		end
  end
end
