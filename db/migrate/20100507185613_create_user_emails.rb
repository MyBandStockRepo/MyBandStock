class CreateUserEmails < ActiveRecord::Migration
  def self.up
    create_table :user_emails do |t|
      t.string :email, :null => false
      t.boolean :confirmed, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :user_emails
  end
end
