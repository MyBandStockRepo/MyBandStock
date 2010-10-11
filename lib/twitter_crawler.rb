require 'FileUtils'
#if the script has been run within the last 5 mintes, don't run it now.
if File.exist?("twitter_crawler_timestamp") && (File.stat("twitter_crawler_timestamp").mtime+300) > Time.now
  puts 'Script was run within the past 5 minutes.  Exiting.'  
else  
  #!/usr/bin/ruby
  RAILS_ENV='development'

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

  #include ActionView::Helpers::UrlHelper
  #include ActionView::Helpers::TagHelper


  #connect activerecord to DB
  dbconfig = YAML::load(File.open(current_directory+'/../config/database.yml'))[RAILS_ENV]
  #ActiveRecord::Base.logger = Logger.new(STDERR)
  ActiveRecord::Base.establish_connection(dbconfig)

  #models
  require current_directory+'/../app/models/twitter_user.rb'
  require current_directory+'/../app/models/twitter_crawler_hash_tag.rb'
  require current_directory+'/../app/models/twitter_crawler_tracker.rb'


  #Connect to Twitter Oauth Stuff
  TWITTERAPI_KEY            = 'OxTeKBSHEM0ufsguoNNeg'
  TWITTERAPI_SECRET_KEY     = 'VFB4ZuSSZ5PDZvhzwjU4NOzh4b1vQHfnBETfYLeOWw'
  TWITTERAPI_ACCESS_TOKEN   = '149205307-PuLfH6MfIjaavon1yFuYAMgr6HIGRIgrdzqRXgGi'
  TWITTERAPI_SECRET_TOKEN   = 'y3PUmN9r7E4uJvw6HUOPMRLfCFmV09ZBwyYC1zLh0'
  oauth = Twitter::OAuth.new(TWITTERAPI_KEY, TWITTERAPI_SECRET_KEY) 
  oauth.authorize_from_access(TWITTERAPI_ACCESS_TOKEN, TWITTERAPI_SECRET_TOKEN) 
  client = Twitter::Base.new(oauth) 

  #can write a function 
  def calc_points_hash_tag(followers)
    return (10*(Math.log(followers+1)+Math.exp(1))).round
  end




  begin
    loop do
      
      for search_item in TwitterCrawlerHashTag.all  
      
        search_term = search_item.term
        last_tweet_id = search_item.last_tweet_id
        rpp = 100
        sleep_num = 10
      
        sleep sleep_num
        result = Twitter::Search.new(search_term).since(last_tweet_id).result_type('recent').per_page(rpp).fetch().results

        #touch the timestamp file saying the script was run
        FileUtils.touch "twitter_crawler_timestamp"
      
        #keep incramenting pages until we find the last tweet we have seen

=begin
        page=1
        while !result.blank? && result.count == rpp && page < 15
          sleep sleep_num        
          page += 1
          result = Twitter::Search.new(search_term).since(last_tweet_id).result_type('recent').per_page(rpp).page(page).fetch().results
        end
        puts 'ON PAGE '+page.to_s
=end
        unless result.blank?
          result = result.reverse
        
          #the from_user_id field is broken in the twitter API and has been for 2+ years now, it doesn't link to the correct user ID, so we must search for it manually
          #this is a painful way of doing it because it means 2x api calls per tweet
          #tried to get user/lookup working with the twitter gem to no avail
          users = result.collect{ |res|
            sleep sleep_num/4
            client.user(res.from_user)
          }
        
        
          count = 0
          for r in result
            #look-up twitter_user
            twitter_user = TwitterUser.where(:twitter_id => users[count].id).first

            #if user not in our system, put them in as a twitter user
            if twitter_user.nil?
              twitter_user = TwitterUser.create(:twitter_id => users[count].id, :name => users[count].name.to_s, :user_name => users[count].screen_name.to_s)
            end

            search_item.last_tweet_id = r.id
            search_item.save

            TwitterCrawlerTracker.create(:tweet_id => r.id, :tweet => r.text.to_s, :twitter_user_id => twitter_user.id, :twitter_crawler_hash_tag_id => search_item.id, :twitter_followers => users[count].followers_count.to_i, :share_value => calc_points_hash_tag(users[count].followers_count.to_i))
          
           puts "@"+twitter_user.name.to_s+" - "+r.text.to_s+"\n\n"
  
            count += 1
          end
          puts "END GROUP of #{result.count}\n\n"
        else
          puts "No results..."
        end    
      end    
    end
  #  TWITTER_CRAWLER_LOG.info '[TWITTER CRAWLER]['+DateTime.now.to_s+'] finishing script'
  rescue
    puts 'error'
    puts $!.to_s+' , LINE: '+$@.to_s  
  #  TWITTER_CRAWLER_LOG.info '[TWITTER CRAWLER]['+DateTime.now.to_s+'] ERROR RAN INTO EXCEPTION'
  #  TWITTER_CRAWLER_LOG.info $!.to_s+' , LINE: '+$@.to_s  
  end
end
