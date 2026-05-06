class MergeHotelDetailsRenameProductsToHotels < ActiveRecord::Migration[8.1]
  def up
    safety = select_value(<<~SQL.squish)
      SELECT COUNT(*)
      FROM products
      WHERE detail_type IS NOT NULL AND detail_type <> 'HotelDetail'
    SQL
    raise ArgumentError, "Non-hotel product rows exist; handle them before this migration" if safety.to_i.positive?

    add_column :products, :type, :string, null: false, default: "Hotel"
    add_column :products, :amenities, :jsonb
    add_column :products, :class_rating, :integer
    add_column :products, :customer_rating, :integer

    execute <<~SQL.squish
      UPDATE products AS p
      SET amenities = hd.amenities,
          class_rating = hd.class_rating,
          customer_rating = hd.customer_rating
      FROM hotel_details AS hd
      WHERE p.detail_id = hd.id AND p.detail_type = 'HotelDetail'
    SQL

    remove_column :products, :detail_id
    remove_column :products, :detail_type

    drop_table :hotel_details

    rename_table :products, :hotels

    execute <<~SQL.squish
      UPDATE images SET imageable_type = 'Hotel' WHERE imageable_type = 'Product'
    SQL

    rename_hotels_indexes_from_products
  end

  def rename_hotels_indexes_from_products
    pairs = [
      %w[index_products_on_destination_id index_hotels_on_destination_id],
      %w[index_products_on_slug index_hotels_on_slug],
      %w[index_products_on_supplier_id_and_supplier_product_id_unique index_hotels_on_supplier_id_and_supplier_product_id_unique],
      %w[index_products_on_supplier_id index_hotels_on_supplier_id],
      %w[index_products_on_supplier_product_id index_hotels_on_supplier_product_id]
    ]
    pairs.each do |old_name, new_name|
      next unless index_exists?(:hotels, name: old_name)

      rename_index :hotels, old_name, new_name
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
