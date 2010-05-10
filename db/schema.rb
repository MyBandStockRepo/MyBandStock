# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100505190204) do

  create_table "associations", :force => true do |t|
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bands", :force => true do |t|
    t.string   "name"
    t.text     "bio"
    t.string   "city"
    t.integer  "zipcode"
    t.string   "band_photo"
    t.string   "status",     :default => "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", :force => true do |t|
    t.string   "name",         :null => false
    t.string   "abbreviation", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "country_ips", :force => true do |t|
    t.string  "begin_ip"
    t.string  "end_ip"
    t.integer "begin_num"
    t.integer "end_num"
    t.string  "country_code"
    t.string  "name"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", :force => true do |t|
    t.string   "name",         :null => false
    t.string   "abbreviation", :null => false
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "streamapi_stream_permissions", :force => true do |t|
    t.boolean  "can_view"
    t.boolean  "can_chat"
    t.string   "stream_quality_level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "streamapi_streams", :force => true do |t|
    t.string   "private_hostid"
    t.string   "public_hostid"
    t.string   "title"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "quality"
    t.boolean  "public"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_roles", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "password"
    t.string   "address"
    t.string   "city"
    t.string   "zipcode"
    t.string   "email"
    t.string   "status",     :default => "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "zipcodes", :force => true do |t|
    t.string "zipcode",   :null => false
    t.string "city",      :null => false
    t.string "state",     :null => false
    t.string "abbr",      :null => false
    t.string "latitude",  :null => false
    t.string "longitude", :null => false
  end

end
