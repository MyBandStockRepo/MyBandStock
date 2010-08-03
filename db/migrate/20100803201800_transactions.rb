class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.string :buyer_id, :serial_number, :google_order_number, :peekok_order_number, {:null => true} 
      #order info
      t.string :financial_order_state, :fulfillment_order_state, {:null => true} 
      t.float :order_total, :total_amount_charged, {:null => true} 
      #the order itself
      t.text :shopping_cart_xml, {:null => true} 
      #address information
      t.string :address1, :address2, :city, {:null => true} 
      t.string:company_name, :contact_name, :country_code, {:null => true} 
      t.string :email, :fax, :phone, :postal_code, :region, {:null => true} 
      #order timestamp
      t.datetime :timestamp, {:null => true} 
      #allow email
      t.boolean :email_allowed, :paid, {:null => true} 
      t.timestamps
      #associations
      t.belongs_to :user
    end
  end

  def self.down
    drop_table :transactions
  end
end
