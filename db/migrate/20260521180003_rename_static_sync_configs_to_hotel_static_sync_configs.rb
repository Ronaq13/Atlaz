class RenameStaticSyncConfigsToHotelStaticSyncConfigs < ActiveRecord::Migration[8.1]
  def up
    rename_table :static_sync_configs, :hotel_static_sync_configs
    remove_column :hotel_static_sync_configs, :from_page
    remove_column :hotel_static_sync_configs, :to_page
  end

  def down
    add_column :hotel_static_sync_configs, :from_page, :integer, default: 1
    add_column :hotel_static_sync_configs, :to_page,   :integer, default: 10
    rename_table :hotel_static_sync_configs, :static_sync_configs
  end
end
