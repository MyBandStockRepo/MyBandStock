ActionMailer::Base.smtp_settings = {
  :address              => "email.mybandstock.com",
  :port                 => 587,
  :domain               => "mybandstock.com",
  :user_name            => "mybandstock",
  :password             => "myb4ndst0ck",
  :authentication       => "plain",
  :enable_starttls_auto => true
}

ActionMailer::Base.default_url_options[:host] = SITE_HOST
Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
