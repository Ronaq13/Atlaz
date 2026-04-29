class CreateCurrencies < ActiveRecord::Migration[8.1]
  def change
    create_table :currencies do |t|
      t.string :code
      t.string :symbol
      t.string :name

      t.timestamps
    end
  end
end
