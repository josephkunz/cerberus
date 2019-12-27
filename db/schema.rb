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

ActiveRecord::Schema.define(version: 2019_12_27_144641) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cases", force: :cascade do |t|
    t.string "name"
    t.string "number"
    t.text "description"
    t.boolean "deleted", default: false
    t.boolean "archived", default: false
    t.bigint "user_id"
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_cases_on_client_id"
    t.index ["user_id"], name: "index_cases_on_user_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "street"
    t.string "city"
    t.string "zipcode"
    t.string "country"
    t.string "company"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "configs", force: :cascade do |t|
    t.boolean "fullpage"
    t.integer "screenshot_width"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "window_width"
    t.integer "window_height"
    t.integer "screenshot_quality"
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.integer "frequency"
    t.string "at"
    t.string "job_name"
    t.jsonb "job_arguments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "infringement_id"
    t.index ["infringement_id"], name: "index_events_on_infringement_id"
  end

  create_table "infringements", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.text "description"
    t.string "interval"
    t.boolean "deleted", default: false
    t.bigint "case_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["case_id"], name: "index_infringements_on_case_id"
  end

  create_table "snapshots", force: :cascade do |t|
    t.datetime "time"
    t.string "image_path"
    t.string "web_path"
    t.text "comment"
    t.boolean "deleted", default: false
    t.bigint "infringement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["infringement_id"], name: "index_snapshots_on_infringement_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "street"
    t.string "city"
    t.string "zip_code"
    t.string "country"
    t.boolean "deleted", default: false
    t.string "company"
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "cases", "clients"
  add_foreign_key "cases", "users"
  add_foreign_key "events", "infringements"
  add_foreign_key "infringements", "cases"
  add_foreign_key "snapshots", "infringements"
end
