#!/usr/bin/ruby

#Crawls twitter looking for hash tags and search terms


#if it has been less than this amount of time since the script ran last, then the script won't run again
#in minutes
script_downtime_minutes_allowed = 5
RAILS_ENV='production'
#twitter results per page (max of 100, set as high as possible to limit api hits)
rpp = 100
#amount of time in seconds to sleep in between api hits
sleep_num = 10
URL_SHORTENER_HOST = 'http://mbs1.us'
SHORT_REGISTRATION_LINK = 'http://mbs1.us/r'
TWEETS_ALLOWED_PER_HOUR = 1


require 'fileutils'
#if the script has been run within the last 5 mintes, don't run it now.
if File.exist?("twitter_crawler_timestamp") && (File.stat("twitter_crawler_timestamp").mtime+(script_downtime_minutes_allowed*60)) > Time.now
  puts 'Script was run within the past '+script_downtime_minutes_allowed.to_s+' minutes.  Exiting.'  
else  

  #get the current directory (the lib folder path)
  current_directory = File.expand_path(File.dirname(__FILE__))

  #Necessary requires since rails isn't running
  require 'rubygems'
  require 'active_record'
  require 'yaml'
  require 'logger'
  require 'twitter'
  


  #connect activerecord to DB
  dbconfig = YAML::load(File.open(current_directory+'/../config/database.yml'))[RAILS_ENV]
  ActiveRecord::Base.establish_connection(dbconfig)
  ActiveRecord::Base.default_timezone = :utc
  
  #models
  require current_directory+'/../app/models/band.rb'
  require current_directory+'/../app/models/twitter_user.rb'
  require current_directory+'/../app/models/twitter_crawler_hash_tag.rb'
  require current_directory+'/../app/models/twitter_crawler_tracker.rb'
  require current_directory+'/../app/models/retweet.rb'
  require current_directory+'/../app/models/user.rb'
  require current_directory+'/../app/models/share_ledger_entry.rb'
  require current_directory+'/../app/models/share_total.rb'
  require current_directory+'/../app/models/short_url.rb'
  
  
  #Connect to Twitter Oauth Stuff
  TWITTERAPI_KEY            = 'OxTeKBSHEM0ufsguoNNeg'
  TWITTERAPI_SECRET_KEY     = 'VFB4ZuSSZ5PDZvhzwjU4NOzh4b1vQHfnBETfYLeOWw'
#  TWITTERAPI_ACCESS_TOKEN   = '149205307-PuLfH6MfIjaavon1yFuYAMgr6HIGRIgrdzqRXgGi'
#  TWITTERAPI_SECRET_TOKEN   = 'y3PUmN9r7E4uJvw6HUOPMRLfCFmV09ZBwyYC1zLh0'
  MBS_REWARD_BOT_ACCESS_TOKEN = '202291092-onrcAsPHAut3EmnLxFvI1Dn6DIMBqTEwSYirVcxc'
  MBS_REWARD_BOT_ACCESS_SECRET = 'fvuBb12KVj7cXWqwSXPk4MqwRTkF4uO2SS3UAxG6lk'  
  oauth = Twitter::OAuth.new(TWITTERAPI_KEY, TWITTERAPI_SECRET_KEY) 
  oauth.authorize_from_access(MBS_REWARD_BOT_ACCESS_TOKEN, MBS_REWARD_BOT_ACCESS_SECRET) 
  client = Twitter::Base.new(oauth) 

  #can write a function #also, similar function in application controller
  def calc_points_hash_tag(followers)
    return (7*(Math.log(followers+1)+Math.exp(1))).round
  end
  
  def randomcode(length=4)
    chars = ("a".."z").to_a + ('A'..'Z').to_a + ("0".."9").to_a;
    Array.new(length, '').collect{chars[rand(chars.size)]}.join
  end
  
  def recent_tweets(twitter_user_id, band_id)
    if band = Band.find(band_id)
      return TwitterCrawlerTracker.where(:twitter_user_id => twitter_user_id, :twitter_crawler_hash_tag_id => band.twitter_crawler_hash_tags.collect{|h|h.id}).where("created_at > ?", Time.now.utc-3600).count
    else
      return nil
    end
  end
  
  #looks for a user in the array and returns a twitter user object, if it can't be found, returns nil
  def find_user_in_array(user_array, screen_name)
    for u in user_array
      if u.screen_name.downcase.to_s == screen_name.downcase.to_s
        return u
      end
    end
    return nil
  end
  
  def tweet_reply(message)
    oauth = Twitter::OAuth.new(TWITTERAPI_KEY, TWITTERAPI_SECRET_KEY) 
    oauth.authorize_from_access(MBS_REWARD_BOT_ACCESS_TOKEN, MBS_REWARD_BOT_ACCESS_SECRET) 
    client = Twitter::Base.new(oauth)
    
    begin
      client.update(message.to_s[0..139])    #dont let it go over 140 characters
    rescue
      
    end
   # puts 'MESSAGE: '+message.to_s
  end


  
  def no_mbs_account_stock_available_reply(twitter_user, band, shares, registration_link)
    tweet_reply("@#{twitter_user.user_name} @#{band.twitter_username} is working w/ @MyBandStock to reward fans for tweeting. You now have BandStock! #{ShortUrl.generate_short_url('http://mybandstock.com/register/twitter/'+band.id.to_s)}")
  end
  def no_mbs_account_no_stock_available_reply(twitter_user, band, shares, registration_link)
    tweet_reply("@#{twitter_user.user_name} @#{band.twitter_username} is working w/ @MyBandStock to reward fans for tweeting. Check it out at #{ShortUrl.generate_short_url('http://mybandstock.com/register/twitter/'+band.id.to_s)}")
  end
  def no_mbs_account_rate_limit_reply(twitter_user, band, shares, registration_link)
    tweet_reply("@#{twitter_user.user_name} @#{band.twitter_username} is working w/ @MyBandStock to reward fans for tweeting. We can only reward #{TWEETS_ALLOWED_PER_HOUR.to_s} per hour, so try later! "+randomcode.to_s)
  end
    
  def yes_mbs_account_stock_available_reply(twitter_user, band, shares)
    tweet_reply("@#{twitter_user.user_name} Yay! You earned #{shares} BandStock in @#{band.twitter_username} and are rank #{twitter_user.users.last.shareholder_rank_for_band(band.id)} on the leaderboard! #{ShortUrl.generate_short_url('http://mybandstock.com/bands/'+band.id.to_s)}")
  end
  def yes_mbs_account_no_stock_available_reply(twitter_user, band, shares)
    tweet_reply("@#{twitter_user.user_name} Thanks for tweeting @#{band.twitter_username}. No more BandStock can be earned today, but you can buy it at #{ShortUrl.generate_short_url('http://mybandstock.com/bands/'+band.id.to_s)}")  
  end
  def yes_mbs_account_rate_limit_reply(twitter_user, band, shares, registration_link)
    tweet_reply("@#{twitter_user.user_name} Thanks for tweeting @#{band.twitter_username}. We can only reward #{TWEETS_ALLOWED_PER_HOUR.to_s} per hour, so try later! "+randomcode.to_s)
  end
  
  begin
    loop do      
      for search_item in TwitterCrawlerHashTag.all        
        search_term = search_item.term
        last_tweet_id = search_item.last_tweet_id
      
        sleep sleep_num
   #     puts 'Looking since: '+last_tweet_id.to_s+' and the actual db reading '+search_item.last_tweet_id.to_s
        result = Twitter::Search.new(search_term).since(last_tweet_id.to_i).result_type('recent').per_page(rpp.to_i).fetch().results

        #lookup users
        unless result.blank?
          users = client.users(result.collect{|res| res.from_user.to_s})
        end

        #touch the timestamp file saying the script was run
        FileUtils.touch "twitter_crawler_timestamp"
      
        #keep incramenting pages until we find the last tweet we have seen
        page=1
        while !result.blank? && (result.count % rpp) == 0 && page < (1500/rpp)
          page += 1          

          result_next_page = Twitter::Search.new(search_term).since(last_tweet_id.to_i).result_type('recent').per_page(rpp.to_i).page(page).fetch().results          
          
          unless result_next_page.blank?
            users_next_page = client.users(result_next_page.collect{|res| res.from_user})
            unless users_next_page.blank?
              result.concat(result_next_page)              
              users.concat(users_next_page)
            end
          end
          puts 'ON PAGE '+page.to_s+' for '+search_term.to_s          
        end

        unless result.blank?
          result = result.uniq
          result = result.reverse
                
          count = 0
          for r in result
            # We must skip consideration of this user if he is MBS_Reward
            if r.from_user == 'MBS_Reward' || (search_item.band.twitter_username && r.from_user == search_item.band.twitter_username)
              search_item.last_tweet_id = r.id.to_s
              search_item.save
              next
            end
            user = find_user_in_array(users, r.from_user)

            unless user.nil?
              #look-up twitter_user
              twitter_user = TwitterUser.where(:twitter_id => user.id).first

              #if user not in our system, put them in as a twitter user
              if twitter_user.nil?
                twitter_user = TwitterUser.create(:twitter_id => user.id, :name => user.name.to_s, :user_name => user.screen_name.to_s)                
              end
              
              #IF MORE THAN X TWEETS PER HOUR, DONT DO A DB ENTRY AND AT REPLY THEM LETTING THEM KNOW SUP
              tweets_in_last_hour = recent_tweets(twitter_user.id, search_item.band.id)
              
              if tweets_in_last_hour.nil? || tweets_in_last_hour >=   TWEETS_ALLOWED_PER_HOUR
                #if user in the system
                if twitter_user.users.last
                  yes_mbs_account_rate_limit_reply(twitter_user, search_item.band, 0, '')
                else
                  no_mbs_account_rate_limit_reply(twitter_user, search_item.band, 0, '')
                end
                search_item.last_tweet_id = r.id.to_s
                search_item.save
                next
              end
              
              
              shares = calc_points_hash_tag(user.followers_count.to_i)
              available_shares = search_item.band.available_shares_for_earning
              if available_shares && available_shares < shares
                shares = available_shares
              end              
          
              #if user in the system, create share ledger entry
              if twitter_user.users.last
                TwitterCrawlerTracker.create(:tweet_id => r.id.to_s, :tweet => r.text.to_s, :twitter_user_id => twitter_user.id, :twitter_crawler_hash_tag_id => search_item.id, :twitter_followers => user.followers_count.to_i, :share_value => shares, :shares_awarded => true)
                
                #user in the system
                #DO @ Replies                                    
                if shares > 0

                  ShareLedgerEntry.create( :user_id => twitter_user.users.last.id,
                                :band_id => search_item.band.id,
                                :adjustment => shares,
                                :description => 'tweeted_band'
                  )
                  band = search_item.band
                  yes_mbs_account_stock_available_reply(twitter_user, band, shares)
                  
                else
                  band = search_item.band
                  yes_mbs_account_no_stock_available_reply(twitter_user, band, shares)
                end
              else
                #user not in the system
                TwitterCrawlerTracker.create(:tweet_id => r.id.to_s, :tweet => r.text.to_s, :twitter_user_id => twitter_user.id, :twitter_crawler_hash_tag_id => search_item.id, :twitter_followers => user.followers_count.to_i, :share_value => shares, :shares_awarded => false)

                #DO @ Replies                
                if shares > 0
                  band = search_item.band
                  no_mbs_account_stock_available_reply(twitter_user, band, shares, 'registration_link')
                else
                  band = search_item.band
                  no_mbs_account_no_stock_available_reply(twitter_user, band, shares, 'registration_link')
                end
              end
          
             puts "@"+twitter_user.name.to_s+" - "+r.text.to_s+"\n\n"
  
              count += 1
            else
              puts 'Couldn\'t find user with screen name '+r.from_user.to_s
            end
            #if the user couldn't be found, skip it and go ahead with the script
            search_item.last_tweet_id = r.id.to_s
            search_item.save
          end
          puts "END GROUP of #{result.count}\n\n"+' for '+search_term.to_s          
        else
          puts "No results..."+' for '+search_term.to_s          
        end    
      end    
    end
  rescue
    puts 'error'
    puts $!.to_s+' , LINE: '+$@.to_s  
  end
end
