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

ActiveRecord::Schema[8.1].define(version: 2026_05_13_160115) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "billing_offers", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "amount_cents", null: false
    t.string "button_label", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "usd", null: false
    t.string "key", null: false
    t.string "mode", null: false
    t.integer "position", default: 0, null: false
    t.string "product_name", null: false
    t.string "recurring_interval"
    t.datetime "updated_at", null: false
    t.index ["active", "position"], name: "index_billing_offers_on_active_and_position"
    t.index ["key"], name: "index_billing_offers_on_key", unique: true
  end

  create_table "evolution_runs", force: :cascade do |t|
    t.string "branch_name"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "pull_request_url"
    t.jsonb "runner_metadata", default: {}, null: false
    t.datetime "started_at"
    t.string "status", default: "reported", null: false
    t.text "summary"
    t.bigint "ticket_id"
    t.datetime "updated_at", null: false
    t.text "validation"
    t.index ["pull_request_url"], name: "index_evolution_runs_on_pull_request_url"
    t.index ["status"], name: "index_evolution_runs_on_status"
    t.index ["ticket_id"], name: "index_evolution_runs_on_ticket_id"
  end

  create_table "feature_usages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_name", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "occurred_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["event_name"], name: "index_feature_usages_on_event_name"
    t.index ["occurred_at"], name: "index_feature_usages_on_occurred_at"
    t.index ["user_id"], name: "index_feature_usages_on_user_id"
  end

  create_table "openai_batch_jobs", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "error_file_id"
    t.string "input_file_id"
    t.jsonb "metadata", default: {}, null: false
    t.string "openai_batch_id"
    t.string "output_file_id"
    t.string "purpose", null: false
    t.datetime "requested_at"
    t.string "status", default: "queued", null: false
    t.datetime "updated_at", null: false
    t.index ["openai_batch_id"], name: "index_openai_batch_jobs_on_openai_batch_id", unique: true
    t.index ["purpose", "status"], name: "index_openai_batch_jobs_on_purpose_and_status"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "amount_total"
    t.datetime "created_at", null: false
    t.string "currency"
    t.string "mode", default: "payment", null: false
    t.string "price_id"
    t.string "status", default: "pending", null: false
    t.string "stripe_checkout_session_id"
    t.string "stripe_customer_id"
    t.string "stripe_invoice_id"
    t.string "stripe_payment_intent_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["status"], name: "index_payments_on_status"
    t.index ["stripe_checkout_session_id"], name: "index_payments_on_stripe_checkout_session_id", unique: true
    t.index ["stripe_customer_id"], name: "index_payments_on_stripe_customer_id"
    t.index ["stripe_invoice_id"], name: "index_payments_on_stripe_invoice_id", unique: true
    t.index ["stripe_payment_intent_id"], name: "index_payments_on_stripe_payment_intent_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_period_end"
    t.string "plan", default: "free", null: false
    t.string "status", default: "free", null: false
    t.string "stripe_customer_id"
    t.string "stripe_subscription_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["stripe_customer_id"], name: "index_subscriptions_on_stripe_customer_id"
    t.index ["stripe_subscription_id"], name: "index_subscriptions_on_stripe_subscription_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "ticket_comments", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.boolean "hidden", default: false, null: false
    t.bigint "ticket_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["hidden"], name: "index_ticket_comments_on_hidden"
    t.index ["ticket_id", "created_at"], name: "index_ticket_comments_on_ticket_id_and_created_at"
    t.index ["ticket_id"], name: "index_ticket_comments_on_ticket_id"
    t.index ["user_id"], name: "index_ticket_comments_on_user_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.datetime "accepted_at"
    t.jsonb "ai_review_metadata", default: {}, null: false
    t.integer "comments_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.bigint "duplicate_ticket_id"
    t.jsonb "embedding"
    t.string "embedding_model"
    t.string "priority", default: "normal", null: false
    t.text "review_reason"
    t.string "review_status", default: "pending", null: false
    t.datetime "reviewed_at"
    t.string "status", default: "open", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "votes_count", default: 0, null: false
    t.index ["accepted_at"], name: "index_tickets_on_accepted_at"
    t.index ["duplicate_ticket_id"], name: "index_tickets_on_duplicate_ticket_id"
    t.index ["priority"], name: "index_tickets_on_priority"
    t.index ["review_status"], name: "index_tickets_on_review_status"
    t.index ["status"], name: "index_tickets_on_status"
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "slug"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "ticket_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["ticket_id"], name: "index_votes_on_ticket_id"
    t.index ["user_id", "ticket_id"], name: "index_votes_on_user_id_and_ticket_id", unique: true
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "evolution_runs", "tickets"
  add_foreign_key "feature_usages", "users"
  add_foreign_key "payments", "users"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "ticket_comments", "tickets"
  add_foreign_key "ticket_comments", "users"
  add_foreign_key "tickets", "tickets", column: "duplicate_ticket_id"
  add_foreign_key "tickets", "users"
  add_foreign_key "votes", "tickets"
  add_foreign_key "votes", "users"
end
