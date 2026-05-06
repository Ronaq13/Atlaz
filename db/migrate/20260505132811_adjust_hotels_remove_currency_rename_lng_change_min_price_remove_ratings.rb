class AdjustHotelsRemoveCurrencyRenameLngChangeMinPriceRemoveRatings < ActiveRecord::Migration[8.1]
  def up
    remove_column :hotels, :ratings, :jsonb
    remove_column :hotels, :currency_id, :bigint
    rename_column :hotels, :lng, :long
    change_column :hotels, :min_price, :jsonb, using: "CASE WHEN min_price IS NULL THEN NULL ELSE to_jsonb(min_price) END"
    add_column :hotels, :hero_image_url, :string
  end

  def down
    change_column :hotels, :min_price, :decimal, using: "CASE WHEN min_price IS NULL THEN NULL ELSE (min_price #>> '{}')::numeric END"
    rename_column :hotels, :long, :lng
    add_column :hotels, :currency_id, :bigint
    add_column :hotels, :ratings, :jsonb
  end
end
