class AddBelongsToFieldsToUserEmail < ActiveRecord::Migration
  def self.up
    add_column :user_emails, :user_id, :integer, {:null => false, :default => 0}
  end

  def self.down
    remove_column :user_emails, :user_id
  end
end
