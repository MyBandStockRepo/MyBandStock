#!/usr/bin/ruby

#Crawls twitter looking for hash tags and search terms


#if it has been less than this amount of time since the script ran last, then the script won't run again
#in minutes
script_downtime_minutes_allowed = 1
RAILS_ENV='development'
#twitter results per page (max of 100, set as high as possible to limit api hits)
rpp = 100
#amount of time in seconds to sleep in between api hits
sleep_num = 5

require 'FileUtils'
#if the script has been run within the last 5 mintes, don't run it now.
if File.exist?("twitter_crawler_timestamp") && (File.stat("twitter_crawler_timestamp").mtime+(script_downtime_minutes_allowed*60)) > Time.now
  puts 'Script was run within the past '+script_downtime_minutes_allowed.to_s+' minutes.  Exiting.'  
else  
  if RAILS_ENV=='development'
    SITE_URL = 'http://127.0.0.1:3000'
    SECURE_SITE_URL = 'http://127.0.0.1:3000'
    SITE_HOST = '127.0.0.1:3000'
  elsif RAILS_ENV=='production'
    SITE_URL = 'http://mybandstock.com'
    SECURE_SITE_URL = 'https://mybandstock.com'
    SITE_HOST = 'mybandstock.com'
  elsif RAILS_ENV=='staging'
    SITE_URL = 'http://gary.mybandstock.com'
    SECURE_SITE_URL = 'http://gary.mybandstock.com'
    SITE_HOST = 'gary.mybandstock.com'
  end

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

  #models
  require current_directory+'/../app/models/twitter_user.rb'
  require current_directory+'/../app/models/twitter_crawler_hash_tag.rb'
  require current_directory+'/../app/models/twitter_crawler_tracker.rb'

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
  
  #looks for a user in the array and returns a twitter user object, if it can't be found, returns nil
  def find_user_in_array(user_array, screen_name)
    for u in user_array
      if u.screen_name.downcase.to_s == screen_name.downcase.to_s
        return u
      end
    end
    return nil
  end
  
  def tweet_reply(to_user)
    oauth = Twitter::OAuth.new(TWITTERAPI_KEY, TWITTERAPI_SECRET_KEY) 
    oauth.authorize_from_access(MBS_REWARD_BOT_ACCESS_TOKEN, MBS_REWARD_BOT_ACCESS_SECRET) 
    client = Twitter::Base.new(oauth)
    client.update('@'+to_user.to_s+' You just earned some bandstock!!  :) :D :O <-- videochat with band!')    
  end
  

  begin
    tweet_reply('bomatson')
    loop do      
      for search_item in TwitterCrawlerHashTag.all        
        search_term = search_item.term
        last_tweet_id = search_item.last_tweet_id
      
        sleep sleep_num
        result = Twitter::Search.new(search_term).since(last_tweet_id).result_type('recent').per_page(rpp).fetch().results

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

          result_next_page = Twitter::Search.new(search_term).since(last_tweet_id).result_type('recent').per_page(rpp).page(page).fetch().results          
          
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
            user = find_user_in_array(users, r.from_user)

            unless user.nil?
              #look-up twitter_user
              twitter_user = TwitterUser.where(:twitter_id => user.id).first

              #if user not in our system, put them in as a twitter user
              if twitter_user.nil?
                twitter_user = TwitterUser.create(:twitter_id => user.id, :name => user.name.to_s, :user_name => user.screen_name.to_s)
              end
              
              TwitterCrawlerTracker.create(:tweet_id => r.id, :tweet => r.text.to_s, :twitter_user_id => twitter_user.id, :twitter_crawler_hash_tag_id => search_item.id, :twitter_followers => user.followers_count.to_i, :share_value => calc_points_hash_tag(user.followers_count.to_i))
          
             puts "@"+twitter_user.name.to_s+" - "+r.text.to_s+"\n\n"
  
              count += 1
            else
              puts 'Couldn\'t find user with screen name '+r.from_user.to_s
            end
            #if the user couldn't be found, skip it and go ahead with the script
            search_item.last_tweet_id = r.id
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
