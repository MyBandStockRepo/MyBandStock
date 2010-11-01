class AddOptOutOfMessagesToTwitterUsers < ActiveRecord::Migration
  def self.up
    add_column :twitter_users, :opt_out_of_messages, :boolean, :default => false
  end

  def self.down
    remove_column :twitter_users, :opt_out_of_messages
  end
end
