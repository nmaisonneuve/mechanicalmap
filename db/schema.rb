# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120323144556) do

  create_table "apps", :force => true do |t|
    t.string   "name",        :null => false
    t.string   "shortname"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "output_ft"
    t.string   "input_ft"
    t.text     "script"
    t.string   "script_url"
    t.text     "ui_template"
    t.integer  "user_id"
  end

  add_index "apps", ["user_id"], :name => "index_apps_on_user_id"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.float    "lat_sw"
    t.float    "lng_sw"
    t.float    "lat_ne"
    t.float    "lng_ne"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "wms_map"
    t.float    "lat_res",     :default => 1.0
    t.float    "lng_res",     :default => 1.0
    t.integer  "redundancy",  :default => 3
    t.string   "ft_id"
    t.text     "script"
    t.string   "script_url"
    t.text     "ui_template"
  end

  create_table "tasks", :force => true do |t|
    t.integer  "app_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.text     "input"
    t.boolean  "gold_answer"
  end

  add_index "tasks", ["app_id"], :name => "index_tasks_on_app_id"

  create_table "units", :force => true do |t|
    t.integer  "task_id"
    t.integer  "state"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "user_id"
    t.text     "answer"
    t.boolean  "ft_sync",    :default => false
  end

  add_index "units", ["task_id"], :name => "index_units_on_task_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.boolean  "anonymous",                             :default => false
    t.string   "username"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
