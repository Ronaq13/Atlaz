class CreateImages < ActiveRecord::Migration[8.1]
  def change
    create_table :images do |t|
      t.references :imageable, polymorphic: true, null: false
      t.string :url
      t.string :thumbnail_url
      t.string :alt_text
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
