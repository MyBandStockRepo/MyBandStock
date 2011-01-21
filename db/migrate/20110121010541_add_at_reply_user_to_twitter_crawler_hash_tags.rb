class AddAtReplyUserToTwitterCrawlerHashTags < ActiveRecord::Migration
  def self.up
    add_column :twitter_crawler_hash_tags, :at_reply_user, :boolean, :default => false
  end

  def self.down
    remove_column :twitter_crawler_hash_tags, :at_reply_user
  end
end
