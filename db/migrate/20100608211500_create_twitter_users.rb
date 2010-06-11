class CreateTwitterUsers < ActiveRecord::Migration
  def self.up
    create_table :twitter_users do |t|
      t.string :name, {:null => true} 
      t.string :user_name, {:null => true} 
      t.integer :twitter_id, {:null => false} 
      t.string :oauth_access_token, {:null => true} 
      t.string :oauth_access_secret, {:null => true} 

      t.timestamps
    end
  end

  def self.down
    drop_table :twitter_users
  end
end
