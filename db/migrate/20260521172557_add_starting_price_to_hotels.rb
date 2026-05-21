class AddStartingPriceToHotels < ActiveRecord::Migration[8.1]
  def change
    add_column    :hotels, :starting_price, :decimal, precision: 10, scale: 2
    add_reference :hotels, :starting_price_currency, foreign_key: { to_table: :currencies }, null: true
  end
end
