class CreateHotelDetails < ActiveRecord::Migration[8.1]
  def change
    create_table :hotel_details do |t|
      t.integer :customer_rating
      t.integer :class_rating
      t.jsonb :amenities

      t.timestamps
    end
  end
end
