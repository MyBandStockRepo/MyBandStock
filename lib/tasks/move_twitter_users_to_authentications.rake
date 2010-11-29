task :move_twitter_users_to_authentications => :environment do
  #migrate from old twitter user model to omniauth and authentications model
  
  users = User.all
  for user in users
    unless user.twitter_user_id.blank?
      twit_user = TwitterUser.find(user.twitter_user_id)
      unless twit_user.blank?
        #make sure authentication doesn't already exist for another user
        prev = Authentication.find_by_provider_and_uid('twitter', twit_user.twitter_id)
        if prev.blank?
          auth = user.authentications.create(:provider => 'twitter', :uid => twit_user.twitter_id)
          unless auth.blank?
            twit_user.authentication_id = auth.id
            twit_user.save
          end
        end          
      end
    end
  end

end
