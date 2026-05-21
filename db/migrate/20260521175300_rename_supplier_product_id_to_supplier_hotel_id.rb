class RenameSupplierProductIdToSupplierHotelId < ActiveRecord::Migration[8.1]
  def change
    rename_column :hotels, :supplier_product_id, :supplier_hotel_id

    if index_exists?(:hotels, name: "index_hotels_on_supplier_id_and_supplier_product_id_unique")
      rename_index :hotels,
        "index_hotels_on_supplier_id_and_supplier_product_id_unique",
        "index_hotels_on_supplier_id_and_supplier_hotel_id_unique"
    end

    if index_exists?(:hotels, name: "index_hotels_on_supplier_product_id")
      rename_index :hotels,
        "index_hotels_on_supplier_product_id",
        "index_hotels_on_supplier_hotel_id"
    end
  end
end
