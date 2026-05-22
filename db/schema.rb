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

ActiveRecord::Schema[8.1].define(version: 2026_05_22_120437) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "currencies", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "symbol"
    t.datetime "updated_at", null: false
  end

  create_table "destinations", force: :cascade do |t|
    t.bigint "country_id"
    t.datetime "created_at", null: false
    t.decimal "latitude", precision: 10, scale: 8, null: false
    t.decimal "longitude", precision: 11, scale: 8, null: false
    t.string "name"
    t.bigint "state_id"
    t.string "type"
    t.datetime "updated_at", null: false
  end

  create_table "hotel_rates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "currency_id", null: false
    t.bigint "hotel_id", null: false
    t.decimal "starting_amount", precision: 12, scale: 2, null: false
    t.datetime "synced_at", null: false
    t.date "till_date", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_hotel_rates_on_currency_id"
    t.index ["hotel_id", "till_date"], name: "index_hotel_rates_on_hotel_id_and_till_date_unique", unique: true
    t.index ["hotel_id"], name: "index_hotel_rates_on_hotel_id"
  end

  create_table "hotel_static_sync_configs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "destination_id", null: false
    t.string "job_name"
    t.string "supplier_destination_id"
    t.datetime "updated_at", null: false
    t.index ["destination_id"], name: "index_hotel_static_sync_configs_on_destination_id"
  end

  create_table "hotels", force: :cascade do |t|
    t.string "address"
    t.jsonb "amenities"
    t.integer "class_rating"
    t.datetime "created_at", null: false
    t.integer "customer_rating"
    t.text "description"
    t.bigint "destination_id", null: false
    t.string "hero_image_url"
    t.decimal "lat"
    t.decimal "long"
    t.jsonb "min_price"
    t.string "name"
    t.string "slug"
    t.string "state"
    t.string "supplier_hotel_id"
    t.bigint "supplier_id"
    t.boolean "sync_rate", default: false, null: false
    t.string "type", default: "Hotel", null: false
    t.datetime "updated_at", null: false
    t.index ["destination_id"], name: "index_hotels_on_destination_id"
    t.index ["slug"], name: "index_hotels_on_slug", unique: true
    t.index ["supplier_hotel_id"], name: "index_hotels_on_supplier_hotel_id"
    t.index ["supplier_id", "supplier_hotel_id"], name: "index_hotels_on_supplier_id_and_supplier_hotel_id_unique", unique: true, where: "((supplier_id IS NOT NULL) AND (supplier_hotel_id IS NOT NULL))"
    t.index ["supplier_id"], name: "index_hotels_on_supplier_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "alt_text"
    t.datetime "created_at", null: false
    t.bigint "imageable_id", null: false
    t.string "imageable_type", null: false
    t.integer "position", default: 0
    t.string "thumbnail_url"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "state", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_suppliers_on_code", unique: true
  end

  add_foreign_key "hotel_rates", "currencies"
  add_foreign_key "hotel_rates", "hotels"
  add_foreign_key "hotel_static_sync_configs", "destinations"
  add_foreign_key "hotels", "destinations"
  add_foreign_key "hotels", "suppliers"
end
