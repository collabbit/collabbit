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

ActiveRecord::Schema.define(:version => 20100211180458) do

  create_table "admins", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password", :limit => 40
    t.string   "salt",             :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attached_files", :force => true do |t|
    t.string   "name"
    t.string   "attach_file_name"
    t.string   "attach_content_type"
    t.integer  "attach_file_size"
    t.datetime "attach_updated_at"
    t.integer  "update_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "carriers", :force => true do |t|
    t.string   "name"
    t.string   "extension"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "classifications", :force => true do |t|
    t.integer  "group_id"
    t.integer  "update_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "update_id"
    t.integer  "user_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "criterions", :force => true do |t|
    t.string   "kind"
    t.string   "requirement"
    t.integer  "feed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feeds", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "owner_id"
    t.integer  "incident_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "text_alert"
    t.boolean  "email_alert"
  end

  create_table "group_taggings", :force => true do |t|
    t.integer "tag_id"
    t.integer "group_id"
  end

  create_table "group_types", :force => true do |t|
    t.string   "name"
    t.integer  "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "groups_count", :default => 0
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.integer  "group_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "memberships_count", :default => 0
  end

  create_table "incidents", :force => true do |t|
    t.string   "name",        :limit => 32
    t.text     "description"
    t.integer  "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "closed_at"
  end

  create_table "instances", :force => true do |t|
    t.string   "short_name", :limit => 16
    t.string   "long_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", :force => true do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.boolean "is_chair"
  end

  create_table "permissions", :force => true do |t|
    t.string   "model"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "privileges", :force => true do |t|
    t.integer  "role_id"
    t.integer  "permission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name",        :limit => 32
    t.integer  "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.integer "update_id"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.integer  "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "updates", :force => true do |t|
    t.string   "title"
    t.text     "text",                 :limit => 255
    t.integer  "user_id"
    t.integer  "incident_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "attached_files_count",                :default => 0
  end

  create_table "users", :force => true do |t|
    t.string   "first_name",                :limit => 100, :default => ""
    t.string   "last_name",                 :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "desk_phone"
    t.string   "desk_phone_ext"
    t.string   "cell_phone"
    t.boolean  "preferred_is_cell"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                    :default => "pending"
    t.datetime "deleted_at"
    t.integer  "role_id"
    t.integer  "instance_id"
    t.integer  "carrier_id"
    t.datetime "last_login"
    t.datetime "last_logout"
    t.datetime "last_alerted"
  end

  create_table "whitelisted_domains", :force => true do |t|
    t.integer  "instance_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
