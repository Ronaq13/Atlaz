class RemoveStartingPriceFromHotels < ActiveRecord::Migration[8.1]
  def up
    remove_column :hotels, :starting_price
    remove_column :hotels, :starting_price_currency_id
  end

  def down
    add_column    :hotels, :starting_price, :decimal, precision: 10, scale: 2
    add_reference :hotels, :starting_price_currency, foreign_key: { to_table: :currencies }, null: true
  end
end
