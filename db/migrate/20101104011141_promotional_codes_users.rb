class PromotionalCodesUsers < ActiveRecord::Migration
  def self.up
     create_table :promotional_codes_users, :id => false do |t|
        t.timestamps
        #references
        t.belongs_to :promotional_code, :user
      end
  		add_index(:promotional_codes_users, [:promotional_code_id, :user_id], :name => 'promotional_codes_users_join_index')    
  end

  def self.down
    drop_table :promotional_codes_users
  end
end