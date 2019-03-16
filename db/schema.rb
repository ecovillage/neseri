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

ActiveRecord::Schema.define(version: 2019_03_16_081923) do

  create_table "instructors", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "address"
    t.string "fax"
    t.string "phone"
    t.string "mobile"
    t.string "homepage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "seminar_instructors", force: :cascade do |t|
    t.integer "seminar_id"
    t.integer "instructor_id"
    t.text "qualification"
    t.boolean "main_contact"
    t.string "accommodation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "comment"
    t.index ["email"], name: "index_seminar_instructors_on_email"
    t.index ["instructor_id"], name: "index_seminar_instructors_on_instructor_id"
    t.index ["seminar_id"], name: "index_seminar_instructors_on_seminar_id"
  end

  create_table "seminar_kinds", force: :cascade do |t|
    t.string "name"
    t.boolean "active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "seminars", force: :cascade do |t|
    t.string "title"
    t.string "subtitle"
    t.text "description"
    t.integer "attendees_minimum"
    t.integer "attendees_maximum"
    t.string "attendees_preconditions"
    t.string "please_bring"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "cancellation_time", default: 7
    t.string "cancellation_reason"
    t.string "room_material"
    t.string "room_extras"
    t.decimal "royalty_participant"
    t.decimal "royalty_participant_reduced"
    t.decimal "material_cost"
    t.decimal "honorar"
    t.string "kind", default: "user"
    t.string "uuid"
    t.boolean "locked", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
    t.integer "seminar_kind_id"
    t.string "accommodation"
    t.index ["creator_id"], name: "index_seminars_on_creator_id"
    t.index ["seminar_kind_id"], name: "index_seminars_on_seminar_kind_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.integer "instructor_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["instructor_id"], name: "index_users_on_instructor_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
