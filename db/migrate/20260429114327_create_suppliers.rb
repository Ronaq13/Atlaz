class CreateSuppliers < ActiveRecord::Migration[8.1]
  def change
    create_table :suppliers do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :state, null: false

      t.timestamps
    end

    add_index :suppliers, :code, unique: true
  end
end
