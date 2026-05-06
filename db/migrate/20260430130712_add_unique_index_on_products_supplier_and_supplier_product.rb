class AddUniqueIndexOnProductsSupplierAndSupplierProduct < ActiveRecord::Migration[8.1]
  def change
    add_index :products,
              %i[supplier_id supplier_product_id],
              unique: true,
              where: "supplier_id IS NOT NULL AND supplier_product_id IS NOT NULL",
              name: "index_products_on_supplier_id_and_supplier_product_id_unique"
  end
end
