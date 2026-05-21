class IncreaseHotelRatesStartingAmountPrecision < ActiveRecord::Migration[8.1]
  def up
    change_column :hotel_rates, :starting_amount, :decimal, precision: 12, scale: 2, null: false
  end

  def down
    change_column :hotel_rates, :starting_amount, :decimal, precision: 10, scale: 2, null: false
  end
end
