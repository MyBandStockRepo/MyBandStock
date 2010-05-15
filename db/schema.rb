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

ActiveRecord::Schema.define(:version => 20100511212421) do

  create_table "api_users", :force => true do |t|
    t.string   "api_key",    :null => false
    t.string   "secret_key", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "associations", :force => true do |t|
    t.string   "type",                      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    :default => 0, :null => false
    t.integer  "band_id",    :default => 0, :null => false
  end

  create_table "bands", :force => true do |t|
    t.string   "name",                             :null => false
    t.text     "bio"
    t.string   "city"
    t.integer  "zipcode"
    t.string   "band_photo"
    t.string   "status",     :default => "active", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "country_id"
    t.integer  "state_id"
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

  create_table "live_stream_series", :force => true do |t|
    t.string   "title",                         :null => false
    t.datetime "start_datetime",                :null => false
    t.datetime "end_datetime",                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "band_id",        :default => 0, :null => false
    t.integer  "api_user_id",    :default => 0, :null => false
  end

  create_table "live_stream_series_permissions", :force => true do |t|
    t.boolean  "can_view",                             :null => false
    t.boolean  "can_listen",                           :null => false
    t.boolean  "can_chat",                             :null => false
    t.string   "stream_quality_level",                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",               :default => 0, :null => false
    t.integer  "live_stream_series_id", :default => 0, :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_id"
    t.integer  "user_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data",       :null => false
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

  create_table "streamapi_streams", :force => true do |t|
    t.string   "private_hostid",                       :null => false
    t.string   "public_hostid",                        :null => false
    t.string   "title",                                :null => false
    t.datetime "start_datetime",                       :null => false
    t.datetime "end_datetime",                         :null => false
    t.string   "layout_path",                          :null => false
    t.string   "skin_path",                            :null => false
    t.boolean  "public",                               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "band_id",               :default => 0, :null => false
    t.integer  "live_stream_series_id", :default => 0, :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "password",                          :null => false
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "zipcode"
    t.string   "phone"
    t.string   "status",     :default => "pending", :null => false
    t.integer  "state_id"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",      :default => "",        :null => false
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
