class CreateStreamapiStreamThemes < ActiveRecord::Migration
  def self.up
    create_table :streamapi_stream_themes do |t|
      t.string :name, :null => false
      t.string :layout_path, :null => false
      t.string :skin_path, :null => false
      t.integer :width, :null => false
      t.integer :height, :null => false
      t.string :quality

      t.timestamps
    end
  end

  def self.down
    drop_table :streamapi_stream_themes
  end
end
