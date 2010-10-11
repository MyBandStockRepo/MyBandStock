class CreateTwitterCrawlerHashTags < ActiveRecord::Migration
  def self.up
    create_table :twitter_crawler_hash_tags do |t|
      t.string :term
      t.integer :last_tweet_id
      t.belongs_to :band

      t.timestamps
    end
  end

  def self.down
    drop_table :twitter_crawler_hash_tags
  end
end
