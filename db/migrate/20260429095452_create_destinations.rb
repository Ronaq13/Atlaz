class CreateDestinations < ActiveRecord::Migration[8.1]
  def change
    create_table :destinations do |t|
      t.string :type
      t.string :name
      t.decimal :latitude, precision: 10, scale: 8, null: false
      t.decimal :longitude, precision: 11, scale: 8, null: false
      t.bigint :state_id
      t.bigint :country_id

      t.timestamps
    end
  end
end
