class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.string :detail_type
      t.bigint :detail_id
      t.bigint :city_id
      t.bigint :state_id
      t.decimal :lat
      t.decimal :lng
      t.string :address
      t.string :state
      t.decimal :min_price
      t.bigint :currency_id
      t.jsonb :ratings
      t.boolean :sync_availability, default: false
      t.boolean :sync_pricing, default: false
      t.datetime :last_availability_synced_at
      t.datetime :last_pricing_synced_at

      t.timestamps
    end

    add_index :products, :slug, unique: true
    add_index :products, :city_id
  end
end
