class ReplaceProductCityStateWithDestination < ActiveRecord::Migration[8.1]
  def up
    remove_index :products, :city_id if index_exists?(:products, :city_id)
    remove_column :products, :city_id
    remove_column :products, :state_id

    add_reference :products, :destination, foreign_key: { to_table: :destinations }, null: false, index: true
  end

  def down
    remove_reference :products, :destination

    add_column :products, :city_id, :bigint
    add_column :products, :state_id, :bigint
    add_index :products, :city_id
  end
end
