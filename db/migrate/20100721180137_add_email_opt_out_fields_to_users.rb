class AddEmailOptOutFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :receive_email_reminders, :boolean, {:null => false, :default => true}
    add_column :users, :receive_email_announcements, :boolean, {:null => false, :default => true}
  end

  def self.down
    remove_column :users, :receive_email_announcements
    remove_column :users, :receive_email_reminders
  end
end
