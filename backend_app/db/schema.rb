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

ActiveRecord::Schema[8.0].define(version: 2025_08_13_090853) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "address_default_status", ["true", "false"]
  create_enum "order_status", ["shipping", "canceled", "successful"]

  create_table "addresses", force: :cascade do |t|
    t.string "unit_number"
    t.string "street_number"
    t.string "region"
    t.string "address_line"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "city_id"
    t.bigint "country_id"
    t.index ["city_id"], name: "index_addresses_on_city_id"
    t.index ["country_id"], name: "index_addresses_on_country_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer "qty", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "cart_id"
    t.bigint "product_id"
    t.index ["cart_id", "product_id"], name: "index_cart_items_on_cart_and_product", unique: true
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
  end

  create_table "carts", force: :cascade do |t|
    t.decimal "total_price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_carts_on_user_id", unique: true
  end

  create_table "cities", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "countries", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_lines", force: :cascade do |t|
    t.integer "qty", default: 1, null: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "product_item_id", null: false
    t.bigint "order_id", null: false
    t.index ["order_id", "product_item_id"], name: "index_order_lines_on_order_and_product_item", unique: true
    t.index ["order_id"], name: "index_order_lines_on_order_id"
    t.index ["product_item_id"], name: "index_order_lines_on_product_item_id"
  end

  create_table "orders", force: :cascade do |t|
    t.decimal "total_price", precision: 10, scale: 2, default: "0.0", null: false
    t.enum "order_status", default: "shipping", null: false, enum_type: "order_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "address_id", null: false
    t.bigint "user_id", null: false
    t.index ["address_id"], name: "index_orders_on_address_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "product_categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_item_variant_options", force: :cascade do |t|
    t.bigint "product_item_id", null: false
    t.bigint "variant_option_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_item_id", "variant_option_id"], name: "index_product_item_variant_options_on_item_and_option", unique: true
    t.index ["product_item_id"], name: "index_product_item_variant_options_on_product_item_id"
    t.index ["variant_option_id"], name: "index_product_item_variant_options_on_variant_option_id"
  end

  create_table "product_items", force: :cascade do |t|
    t.string "sku", null: false
    t.integer "qty_in_stock", default: 0, null: false
    t.string "image"
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "product_id"
    t.index ["product_id", "sku"], name: "index_product_items_on_product_and_sku", unique: true
    t.index ["product_id"], name: "index_product_items_on_product_id"
    t.index ["sku"], name: "index_product_items_on_sku", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "product_category_id"
    t.index ["product_category_id"], name: "index_products_on_product_category_id"
  end

  create_table "user_addresses", force: :cascade do |t|
    t.enum "is_default", default: "false", null: false, enum_type: "address_default_status"
    t.bigint "user_id"
    t.bigint "address_id"
    t.index ["address_id"], name: "index_user_addresses_on_address_id"
    t.index ["user_id"], name: "index_user_addresses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "phone_number"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "variant_options", force: :cascade do |t|
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "variant_id", null: false
    t.index ["variant_id"], name: "index_variant_options_on_variant_id"
  end

  create_table "variants", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "product_category_id"
    t.index ["product_category_id"], name: "index_variants_on_product_category_id"
  end

  add_foreign_key "addresses", "cities"
  add_foreign_key "addresses", "countries"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "order_lines", "orders"
  add_foreign_key "order_lines", "product_items"
  add_foreign_key "orders", "addresses"
  add_foreign_key "product_item_variant_options", "product_items"
end
