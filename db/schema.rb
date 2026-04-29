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

ActiveRecord::Schema[8.1].define(version: 2026_04_29_111713) do
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

  create_table "hotel_details", force: :cascade do |t|
    t.jsonb "amenities"
    t.integer "class_rating"
    t.datetime "created_at", null: false
    t.integer "customer_rating"
    t.datetime "updated_at", null: false
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

  create_table "products", force: :cascade do |t|
    t.string "address"
    t.bigint "city_id"
    t.datetime "created_at", null: false
    t.bigint "currency_id"
    t.text "description"
    t.bigint "detail_id"
    t.string "detail_type"
    t.datetime "last_availability_synced_at"
    t.datetime "last_pricing_synced_at"
    t.decimal "lat"
    t.decimal "lng"
    t.decimal "min_price"
    t.string "name"
    t.jsonb "ratings"
    t.string "slug"
    t.string "state"
    t.bigint "state_id"
    t.boolean "sync_availability", default: false
    t.boolean "sync_pricing", default: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_products_on_city_id"
    t.index ["slug"], name: "index_products_on_slug", unique: true
  end
end
