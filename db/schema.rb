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

ActiveRecord::Schema.define(version: 20160301033002) do

  create_table "contacts", force: :cascade do |t|
    t.string   "name"
    t.string   "phone"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "contacts", ["user_id"], name: "index_contacts_on_user_id"

  create_table "frequencies", force: :cascade do |t|
    t.date     "start_date"
    t.time     "time"
    t.boolean  "repeat"
    t.boolean  "sunday"
    t.boolean  "monday"
    t.boolean  "tuesday"
    t.boolean  "wednesday"
    t.boolean  "thursday"
    t.boolean  "friday"
    t.boolean  "saturday"
    t.integer  "schedule_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "timezone"
  end

  add_index "frequencies", ["schedule_id"], name: "index_frequencies_on_schedule_id"

  create_table "occurences", force: :cascade do |t|
    t.datetime "time"
    t.integer  "schedule_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "occurences", ["schedule_id"], name: "index_occurences_on_schedule_id"

  create_table "scheduled_calls", force: :cascade do |t|
    t.string   "call_id"
    t.integer  "occurence_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.datetime "call_timestamp"
  end

  add_index "scheduled_calls", ["occurence_id"], name: "index_scheduled_calls_on_occurence_id"

  create_table "schedules", force: :cascade do |t|
    t.string   "message"
    t.datetime "next_call_time"
    t.datetime "last_successful_summit_request"
    t.integer  "contact_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "user_id"
    t.date     "last_occurence_date"
  end

  add_index "schedules", ["contact_id"], name: "index_schedules_on_contact_id"
  add_index "schedules", ["user_id"], name: "index_schedules_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "name"
    t.string   "subscription"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
