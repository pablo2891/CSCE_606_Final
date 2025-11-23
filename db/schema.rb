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

ActiveRecord::Schema[8.0].define(version: 2025_11_22_004000) do
  create_table "company_verifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "company_email", null: false
    t.string "company_name", null: false
    t.boolean "is_verified", default: false
    t.string "verification_token"
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "company_email"], name: "index_company_verifications_on_user_id_and_company_email", unique: true
    t.index ["user_id"], name: "index_company_verifications_on_user_id"
    t.index ["verification_token"], name: "index_company_verifications_on_verification_token", unique: true
  end

  create_table "conversations", force: :cascade do |t|
    t.integer "sender_id", null: false
    t.integer "recipient_id", null: false
    t.string "subject"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id"], name: "index_conversations_on_recipient_id"
    t.index ["sender_id"], name: "index_conversations_on_sender_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "conversation_id", null: false
    t.integer "user_id", null: false
    t.text "body", null: false
    t.boolean "read", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "referral_posts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "company_verification_id", null: false
    t.string "company_name", null: false
    t.string "title", null: false
    t.text "description"
    t.text "job_openings_links"
    t.integer "status", default: 0, null: false
    t.json "additional_criteria", default: {}
    t.json "request_criteria", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "job_title"
    t.string "department"
    t.string "location"
    t.string "job_level"
    t.string "employment_type"
    t.text "why_referring"
    t.json "questions"
    t.index ["company_name"], name: "index_referral_posts_on_company_name"
    t.index ["company_verification_id"], name: "index_referral_posts_on_company_verification_id"
    t.index ["user_id"], name: "index_referral_posts_on_user_id"
  end

  create_table "referral_requests", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "referral_post_id", null: false
    t.text "note_to_poster"
    t.json "submitted_data", default: {}
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["referral_post_id"], name: "index_referral_requests_on_referral_post_id"
    t.index ["user_id", "referral_post_id"], name: "index_referral_requests_on_user_id_and_referral_post_id", unique: true
    t.index ["user_id"], name: "index_referral_requests_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.boolean "is_tamu_verified", default: false
    t.string "tamu_verification_token"
    t.datetime "tamu_verified_at"
    t.string "headline"
    t.text "summary"
    t.string "resume_url"
    t.string "linkedin_url"
    t.string "github_url"
    t.json "experiences_data", default: [], null: false
    t.json "educations_data", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["tamu_verification_token"], name: "index_users_on_tamu_verification_token", unique: true
  end

  add_foreign_key "company_verifications", "users"
  add_foreign_key "conversations", "users", column: "recipient_id"
  add_foreign_key "conversations", "users", column: "sender_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
  add_foreign_key "referral_posts", "company_verifications"
  add_foreign_key "referral_posts", "users"
  add_foreign_key "referral_requests", "referral_posts"
  add_foreign_key "referral_requests", "users"
end
