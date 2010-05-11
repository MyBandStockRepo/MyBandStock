class UserNotifier < ActionMailer::Base
  
  #content_type defaults to plain/text
  
  def welcome(user_id)
    user = User.find(user_id)
    
    recipients  user.email
    from        'no-reply@mybandstock.com'
    reply_to    'no-reply@mybandstock.com'
    subject     'Welcome to MyBandStock.  Thanks for registering.'
    sent_on     Time.now
    
    body[:name] = user.full_name
    body[:email] = user.email
    body[:password] = user.password
    
  end
  
  
  def password_reminder(user_id)
    user = User.find(user_id)
    
    recipients  user.email
    from        'no-reply@mybandstock.com'
    reply_to    'no-reply@mybandstock.com'
    subject     'MyBandStock: Password Reminder'
    sent_on     Time.now
    
    body[:email] = user.email
    body[:password] = user.password
  end
  
  
  def band_application_approved(user_id, band_application_id)
    band_application = BandApplication.find(band_application_id)
    user = User.find(user_id)
    
    recipients  user.email
    from        'no-reply@mybandstock.com'
    reply_to    'no-reply@mybandstock.com'
    subject     "Welcome to MyBandStock #{band_application.band_name}"
    sent_on     Time.now
    
    body[:band_name] = band_application.band_name
  end
  
  def project_approved(band_id, project_id)
    band = Band.find(band_id)
    project = Project.find(project_id)
    
    recipients  band.admins.collect{|a| a.email}
    from        'no-reply@mybandstock.com'
    reply_to    'no-reply@mybandstock.com'
    subject     'MyBandStock: Project approved'
    sent_on     Time.now
    
    body[:project_name] = project.name
    
    end
  
  
  def project_activated(band_id, project_id)
    band = Band.find(band_id)
    project = Project.find(project_id)
    
    recipients  band.admins.collect{|a| a.email}
    from        'no-reply@mybandstock.com'
    reply_to    'no-reply@mybandstock.com'
    subject     'MyBandStock: Project approved'
    sent_on     Time.now
    
    body[:project_name] = project.name
  end
  
#end controller
end
