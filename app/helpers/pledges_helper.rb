module PledgesHelper
  
  #If usee within the same session is pledging twice prepulate name and email values in plede_suggestion view
  def get_name_value
    if !session[:full_name].nil?
      return session[:full_name]
    else
      return "Name"
    end
  end
  
  def get_email_value
    if !session[:email].nil?
      return session[:email]
    else
      return "Email"
    end
  end
  
end
