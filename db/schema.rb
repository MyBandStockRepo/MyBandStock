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

ActiveRecord::Schema.define(:version => 20100608195220) do

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
    t.string   "name",                                      :null => false
    t.string   "short_name",                                :null => false
    t.text     "bio"
    t.boolean  "terms_of_service",    :default => false,    :null => false
    t.string   "city",                                      :null => false
    t.integer  "zipcode",                                   :null => false
    t.string   "band_photo"
    t.string   "status",              :default => "active", :null => false
    t.string   "twitter_user"
    t.string   "external_css_link"
    t.string   "access_schedule_url"
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
    t.string   "title",        :null => false
    t.datetime "starts_at",    :null => false
    t.datetime "ends_at",      :null => false
    t.string   "purchase_url"
    t.integer  "band_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "live_stream_series_permissions", :force => true do |t|
    t.boolean  "can_view",                                 :null => false
    t.boolean  "can_listen",            :default => false, :null => false
    t.boolean  "can_chat",              :default => false, :null => false
    t.string   "stream_quality_level"
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

  create_table "share_code_groups", :force => true do |t|
    t.string   "label"
    t.integer  "start_share_code_id",                     :null => false
    t.integer  "num_share_codes",                         :null => false
    t.boolean  "active",                :default => true, :null => false
    t.integer  "share_amount"
    t.datetime "expiration_date"
    t.integer  "live_stream_series_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "share_codes", :force => true do |t|
    t.string   "key",                                    :null => false
    t.boolean  "redeemed",            :default => false, :null => false
    t.integer  "share_code_group_id"
    t.integer  "user_id",             :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "share_codes", ["key"], :name => "index_share_codes_on_key", :unique => true

  create_table "short_urls", :force => true do |t|
    t.string   "destination",                     :null => false
    t.string   "key",                             :null => false
    t.integer  "maker_id"
    t.string   "maker_type",  :default => "User"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "short_urls", ["key"], :name => "index_short_urls_on_key", :unique => true

  create_table "states", :force => true do |t|
    t.string   "name",         :null => false
    t.string   "abbreviation", :null => false
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "twitter_users", :force => true do |t|
    t.string   "name"
    t.string   "user_name"
    t.integer  "twitter_id",          :null => false
    t.string   "oauth_access_token"
    t.string   "oauth_access_secret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "streamapi_stream_themes", :force => true do |t|
    t.string   "name",        :null => false
    t.string   "layout_path", :null => false
    t.string   "skin_path",   :null => false
    t.integer  "width",       :null => false
    t.integer  "height",      :null => false
    t.string   "quality"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "streamapi_stream_viewer_statuses", :force => true do |t|
    t.string   "ip_address"
    t.string   "viewer_key",          :null => false
    t.integer  "streamapi_stream_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "streamapi_stream_viewer_statuses", ["viewer_key"], :name => "index_streamapi_stream_viewer_statuses_on_viewer_key", :unique => true

  create_table "streamapi_streams", :force => true do |t|
    t.string   "private_hostid"
    t.string   "public_hostid"
    t.string   "channel_id"
    t.string   "title",                                    :null => false
    t.datetime "starts_at",                                :null => false
    t.datetime "ends_at",                                  :null => false
    t.boolean  "public",                 :default => true, :null => false
    t.integer  "duration"
    t.integer  "total_viewers"
    t.integer  "max_concurrent_viewers"
    t.string   "recording_filename"
    t.string   "recording_url"
    t.string   "live_url"
    t.integer  "band_id"
    t.integer  "live_stream_series_id"
    t.integer  "broadcaster_theme_id"
    t.integer  "viewer_theme_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location"
  end

  create_table "urls", :force => true do |t|
    t.string   "destination",                     :null => false
    t.string   "key",                             :null => false
    t.integer  "maker_id"
    t.string   "maker_type",  :default => "User"
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
