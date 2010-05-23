ActionMailer::Base.smtp_settings = {
  :address              => "email.mybandstock.com",
  :port                 => 587,
  :domain               => "mybandstock.com",
  :user_name            => "mybandstock",
  :password             => "myb4ndst0ck",
  :authentication       => "plain",
  :enable_starttls_auto => true
}

