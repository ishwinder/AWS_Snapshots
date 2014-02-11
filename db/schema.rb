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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140210120441) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ami_instances", force: true do |t|
    t.string   "instance_id"
    t.string   "region"
    t.integer  "scheduled_ami_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ami_instances", ["scheduled_ami_id"], name: "index_ami_instances_on_scheduled_ami_id", using: :btree

  create_table "ami_summaries", force: true do |t|
    t.string   "name"
    t.string   "ami_id"
    t.string   "instance_id"
    t.integer  "scheduled_ami_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ami_summaries", ["scheduled_ami_id"], name: "index_ami_summaries_on_scheduled_ami_id", using: :btree
  add_index "ami_summaries", ["user_id"], name: "index_ami_summaries_on_user_id", using: :btree

  create_table "events", force: true do |t|
    t.string   "name"
    t.integer  "action"
    t.integer  "frequency"
    t.integer  "day_of_week"
    t.integer  "day_of_month"
    t.time     "event_time"
    t.text     "cron"
    t.integer  "schedule_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["schedule_id"], name: "index_events_on_schedule_id", using: :btree

  create_table "images", force: true do |t|
    t.string   "name"
    t.string   "image_id"
    t.string   "image_state"
    t.boolean  "is_public"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instance_types", force: true do |t|
    t.string   "name"
    t.decimal  "memory"
    t.decimal  "cost"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instances", force: true do |t|
    t.string   "instance"
    t.string   "region"
    t.integer  "schedule_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "instances", ["schedule_id"], name: "index_instances_on_schedule_id", using: :btree

  create_table "scheduled_amis", force: true do |t|
    t.string   "name"
    t.string   "schedule_name"
    t.string   "description"
    t.boolean  "no_reboot"
    t.integer  "frequency"
    t.integer  "day_of_week"
    t.integer  "day_of_month"
    t.time     "event_time"
    t.text     "cron"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scheduled_snapshots", force: true do |t|
    t.string   "volume_id"
    t.string   "description"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "frequency"
    t.time     "start_time"
    t.string   "time_of_day"
    t.string   "day_of_week"
    t.string   "month_of_year"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "cron"
    t.integer  "retention_period"
    t.string   "region"
  end

  create_table "scheduled_summaries", force: true do |t|
    t.integer  "action"
    t.string   "instance_id"
    t.boolean  "status"
    t.integer  "schedule_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scheduled_summaries", ["schedule_id"], name: "index_scheduled_summaries_on_schedule_id", using: :btree
  add_index "scheduled_summaries", ["user_id"], name: "index_scheduled_summaries_on_user_id", using: :btree

  create_table "schedules", force: true do |t|
    t.string   "name"
    t.string   "status"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schedules", ["user_id"], name: "index_schedules_on_user_id", using: :btree

  create_table "snapshot_summaries", force: true do |t|
    t.string   "snapshot_id"
    t.string   "volume_id"
    t.datetime "start_time"
    t.integer  "scheduled_snapshot_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "auto_delete_on"
  end

  add_index "snapshot_summaries", ["scheduled_snapshot_id"], name: "index_snapshot_summaries_on_scheduled_snapshot_id", using: :btree
  add_index "snapshot_summaries", ["user_id"], name: "index_snapshot_summaries_on_user_id", using: :btree

  create_table "tags", force: true do |t|
    t.string  "key"
    t.string  "value"
    t.integer "tagable_id"
    t.string  "tagable_type"
  end

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email",                  default: "",          null: false
    t.string   "encrypted_password",     default: "",          null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,           null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "access_key"
    t.string   "secret_token"
    t.string   "default_region",         default: "us-east-1"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
