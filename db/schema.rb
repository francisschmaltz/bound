# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160901134311) do

  create_table "api_tokens", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "token"
    t.datetime "last_used_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "authie_sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "token"
    t.string   "browser_id"
    t.integer  "user_id"
    t.boolean  "active",                           default: true
    t.text     "data",               limit: 65535
    t.datetime "expires_at"
    t.datetime "login_at"
    t.string   "login_ip"
    t.datetime "last_activity_at"
    t.string   "last_activity_ip"
    t.string   "last_activity_path"
    t.string   "user_agent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_type"
    t.integer  "parent_id"
    t.datetime "two_factored_at"
    t.string   "two_factored_ip"
    t.integer  "requests",                         default: 0
    t.datetime "password_seen_at"
    t.index ["browser_id"], name: "index_authie_sessions_on_browser_id", using: :btree
    t.index ["token"], name: "index_authie_sessions_on_token", using: :btree
    t.index ["user_id"], name: "index_authie_sessions_on_user_id", using: :btree
  end

  create_table "changes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "zone_id"
    t.integer  "user_id"
    t.string   "event"
    t.string   "name"
    t.string   "attribute_name"
    t.string   "old_value",      limit: 4096
    t.string   "new_value",      limit: 4096
    t.datetime "published_at"
    t.integer  "serial"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "records", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "zone_id"
    t.string   "name"
    t.string   "type"
    t.string   "data",       limit: 4096
    t.integer  "ttl"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "email_address"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "invite_token"
  end

  create_table "zones", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "primary_ns"
    t.string   "email_address"
    t.integer  "serial"
    t.integer  "refresh_time"
    t.integer  "retry_time"
    t.integer  "expiration_time"
    t.integer  "max_cache"
    t.integer  "ttl"
    t.datetime "published_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
