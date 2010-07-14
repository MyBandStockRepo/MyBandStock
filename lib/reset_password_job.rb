class ResetPasswordJob < Struct.new(:user, :password)
  def perform
    UserMailer.reset_password(user, password).deliver
  end  
end
