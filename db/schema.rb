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

ActiveRecord::Schema.define(:version => 20100514193600) do

  create_table "api_users", :force => true do |t|
    t.string   "api_key",    :null => false
    t.string   "secret_key", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "api_users_live_stream_series", :id => false, :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "api_user_id"
    t.integer  "live_stream_series_id"
  end

  create_table "associations", :force => true do |t|
    t.string   "name",       :null => false
    t.integer  "user_id"
    t.integer  "band_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bands", :force => true do |t|
    t.string   "name",                                   :null => false
    t.string   "short_name",                             :null => false
    t.text     "bio"
    t.boolean  "terms_of_service", :default => false,    :null => false
    t.string   "city",                                   :null => false
    t.integer  "zipcode",                                :null => false
    t.string   "band_photo"
    t.string   "status",           :default => "active", :null => false
    t.string   "twitter_user"
    t.integer  "country_id"
    t.integer  "state_id"
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

  create_table "live_stream_series", :force => true do |t|
    t.string   "title",      :null => false
    t.datetime "starts_at",  :null => false
    t.datetime "ends_at",    :null => false
    t.integer  "band_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "live_stream_series_permissions", :force => true do |t|
    t.boolean  "can_view",                                :null => false
    t.boolean  "can_listen",                              :null => false
    t.boolean  "can_chat",                                :null => false
    t.string   "stream_quality_level",                    :null => false
    t.boolean  "currently_viewing",     :default => true, :null => false
    t.integer  "user_id"
    t.integer  "live_stream_series_id"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  add_index "roles_users", ["role_id", "user_id"], :name => "roles_users_join_index"

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "states", :force => true do |t|
    t.string   "name",         :null => false
    t.string   "abbreviation", :null => false
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "streamapi_streams", :force => true do |t|
    t.string   "private_hostid",        :null => false
    t.string   "public_hostid",         :null => false
    t.string   "title",                 :null => false
    t.datetime "starts_at",             :null => false
    t.datetime "ends_at",               :null => false
    t.string   "layout_path",           :null => false
    t.string   "skin_path",             :null => false
    t.boolean  "public",                :null => false
    t.integer  "band_id"
    t.integer  "live_stream_series_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "password",                                 :null => false
    t.text     "bio"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "email",                                    :null => false
    t.string   "zipcode"
    t.string   "phone"
    t.boolean  "agreed_to_tos",     :default => false,     :null => false
    t.boolean  "agreed_to_pp",      :default => false,     :null => false
    t.integer  "headline_photo_id"
    t.string   "status",            :default => "pending", :null => false
    t.integer  "country_id"
    t.integer  "state_id"
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
