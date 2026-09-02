# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_19_135144) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ahoy_messages", force: :cascade do |t|
    t.text "content"
    t.string "mailer"
    t.datetime "sent_at", precision: nil
    t.text "subject"
    t.text "to"
    t.integer "user_id"
    t.string "user_type"
    t.index ["user_type", "user_id"], name: "index_ahoy_messages_on_user_type_and_user_id"
  end

  create_table "publication_user_mappings", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.string "uuid"
    t.index ["user_id"], name: "index_publication_user_mappings_on_user_id"
  end

  create_table "publications", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "seminar_id"
    t.datetime "updated_at", precision: nil, null: false
    t.string "uuid"
    t.index ["seminar_id"], name: "index_publications_on_seminar_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", precision: nil, null: false
    t.text "kind"
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["kind"], name: "index_rooms_on_kind"
  end

  create_table "seminar_instructors", id: :integer, default: nil, force: :cascade do |t|
    t.string "accommodation"
    t.string "address"
    t.string "comment"
    t.boolean "contactable", default: false
    t.datetime "created_at", precision: nil, null: false
    t.string "email"
    t.string "fax"
    t.string "firstname"
    t.string "homepage"
    t.string "lastname"
    t.boolean "main_contact"
    t.string "mobile"
    t.string "phone"
    t.text "qualification"
    t.integer "seminar_id"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["email"], name: "index_seminar_instructors_on_email"
    t.index ["seminar_id"], name: "index_seminar_instructors_on_seminar_id"
    t.index ["user_id"], name: "index_seminar_instructors_on_user_id"
  end

  create_table "seminar_kinds", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", precision: nil, null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "seminars", force: :cascade do |t|
    t.string "accommodation"
    t.boolean "active", default: true
    t.text "alternative_dates"
    t.integer "attendees_maximum"
    t.integer "attendees_minimum"
    t.string "attendees_preconditions"
    t.string "cancellation_reason"
    t.integer "cancellation_time", default: 7
    t.decimal "cost_participant", precision: 8, scale: 2
    t.decimal "cost_participant_reduced", precision: 8, scale: 2
    t.datetime "created_at", precision: nil, null: false
    t.integer "creator_id"
    t.text "description"
    t.datetime "end_date", precision: nil
    t.string "kind", default: "user"
    t.boolean "locked", default: false
    t.decimal "material_cost", precision: 8, scale: 2
    t.text "media_coverage_links"
    t.text "other_extras"
    t.string "please_bring"
    t.datetime "privacy_terms_accepted_at", precision: nil
    t.text "room_comment"
    t.string "room_material"
    t.integer "room_wish_id"
    t.decimal "royalty_participant", precision: 8, scale: 2
    t.decimal "royalty_participant_reduced", precision: 8, scale: 2
    t.integer "seminar_kind_id"
    t.datetime "start_date", precision: nil
    t.string "subtitle"
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_seminar_id"
    t.string "uuid"
    t.index ["creator_id"], name: "index_seminars_on_creator_id"
    t.index ["room_wish_id"], name: "index_seminars_on_room_wish_id"
    t.index ["seminar_kind_id"], name: "index_seminars_on_seminar_kind_id"
    t.index ["user_seminar_id"], name: "index_seminars_on_user_seminar_id"
  end

  create_table "settings", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "key"
    t.datetime "updated_at", precision: nil, null: false
    t.string "value"
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "users", id: :integer, default: nil, force: :cascade do |t|
    t.string "address"
    t.boolean "admin", default: false
    t.datetime "confirmation_sent_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "fax"
    t.string "firstname"
    t.string "homepage"
    t.datetime "invitation_accepted_at", precision: nil
    t.datetime "invitation_created_at", precision: nil
    t.integer "invitation_limit"
    t.datetime "invitation_sent_at", precision: nil
    t.string "invitation_token"
    t.integer "invitations_count", default: 0
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.string "lastname"
    t.string "mobile"
    t.string "phone"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.datetime "tos_accepted_at", precision: nil
    t.string "unconfirmed_email"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "publication_user_mappings", "users"
  add_foreign_key "publications", "seminars"
end
