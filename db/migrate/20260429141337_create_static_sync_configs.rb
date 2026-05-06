class CreateStaticSyncConfigs < ActiveRecord::Migration[8.1]
  def change
    create_table :static_sync_configs do |t|
      t.references :destination, null: false, foreign_key: true
      t.string :supplier_destination_id
      t.string :job_name
      t.integer :from_page, default: 1
      t.integer :to_page, default: 10
      t.integer :page_size, default: 20

      t.timestamps
    end
  end
end
