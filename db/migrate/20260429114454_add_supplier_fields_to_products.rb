class AddSupplierFieldsToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :supplier_id, :bigint
    add_column :products, :supplier_product_id, :string

    add_index :products, :supplier_id
    add_index :products, :supplier_product_id

    add_foreign_key :products, :suppliers
  end
end
