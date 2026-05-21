class CreateHotelRates < ActiveRecord::Migration[8.1]
  def change
    create_table :hotel_rates do |t|
      t.references :hotel,    null: false, foreign_key: true
      t.references :currency, null: false, foreign_key: true
      t.decimal    :starting_amount, precision: 10, scale: 2, null: false
      t.date       :till_date,  null: false   # check_in date of the lookahead window
      t.datetime   :synced_at, null: false

      t.timestamps
    end

    # One price bucket per hotel per lookahead window, refreshed daily.
    add_index :hotel_rates, %i[hotel_id till_date],
              unique: true,
              name: "index_hotel_rates_on_hotel_id_and_till_date_unique"
  end
end
