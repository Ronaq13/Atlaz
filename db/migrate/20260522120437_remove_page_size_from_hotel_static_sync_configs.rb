class RemovePageSizeFromHotelStaticSyncConfigs < ActiveRecord::Migration[8.1]
  def up
    remove_column :hotel_static_sync_configs, :page_size
  end

  def down
    add_column :hotel_static_sync_configs, :page_size, :integer, default: 20
  end
end
