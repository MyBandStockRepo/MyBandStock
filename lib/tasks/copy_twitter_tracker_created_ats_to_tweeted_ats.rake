task :copy_twitter_tracker_created_ats_to_tweeted_ats => :environment do
  #copy over the twitter_created_at fields to tweeted_at
  
  tweets = TwitterCrawlerTracker.where(:tweeted_at => nil).all
  
  for tweet in tweets
    begin
      tweet.tweeted_at = Twitter.status(tweet.tweet_id).created_at
      tweet.save
    rescue
#      tweet.tweeted_at = tweet.created_at
#      tweet.save
    end
    sleep 1
  end
end
