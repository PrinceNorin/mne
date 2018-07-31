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

ActiveRecord::Schema.define(version: 20180731120517) do

  create_table "business_plans", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "license_id"
    t.integer "currency", default: 0
    t.text "content"
    t.decimal "budget", precision: 16, scale: 6, default: "0.0"
    t.integer "employees"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["license_id"], name: "index_business_plans_on_license_id"
  end

  create_table "categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.float "tax_rate", limit: 24
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "companies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "owner"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "licenses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "number", null: false
    t.integer "status", default: 0
    t.decimal "total_area", precision: 16, scale: 6, null: false
    t.integer "area_unit", default: 0
    t.integer "province", default: 0
    t.date "issue_at", null: false
    t.date "expire_at", null: false
    t.date "valid_at", null: false
    t.text "business_address"
    t.text "note"
    t.string "company_name", null: false
    t.string "owner_name"
    t.string "category_name", null: false
    t.bigint "company_id"
    t.bigint "category_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_licenses_on_category_id"
    t.index ["company_id"], name: "index_licenses_on_company_id"
    t.index ["deleted_at"], name: "index_licenses_on_deleted_at"
  end

  create_table "statements", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "number"
    t.bigint "reference_id"
    t.bigint "license_id"
    t.date "issued_date"
    t.integer "statement_type", default: 0
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_statements_on_deleted_at"
    t.index ["license_id"], name: "index_statements_on_license_id"
    t.index ["reference_id"], name: "index_statements_on_reference_id", unique: true
  end

  create_table "taxes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "license_id"
    t.float "rate", limit: 24
    t.decimal "unit", precision: 16, scale: 6
    t.decimal "total", precision: 16, scale: 6
    t.date "from"
    t.date "to"
    t.integer "tax_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "currency", default: 1
    t.index ["license_id"], name: "index_taxes_on_license_id"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "item_type", limit: 191, null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", limit: 4294967295
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "business_plans", "licenses"
  add_foreign_key "licenses", "categories"
  add_foreign_key "licenses", "companies"
  add_foreign_key "statements", "licenses"
  add_foreign_key "taxes", "licenses"
end
