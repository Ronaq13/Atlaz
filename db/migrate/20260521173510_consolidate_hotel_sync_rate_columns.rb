class ConsolidateHotelSyncRateColumns < ActiveRecord::Migration[8.1]
  def up
    remove_column :hotels, :sync_availability
    remove_column :hotels, :sync_pricing
    add_column    :hotels, :sync_rate, :boolean, default: false, null: false

    remove_column :hotels, :last_availability_synced_at
    remove_column :hotels, :last_pricing_synced_at
    add_column    :hotels, :rates_synced_at, :datetime
  end

  def down
    remove_column :hotels, :sync_rate
    add_column    :hotels, :sync_availability, :boolean, default: false
    add_column    :hotels, :sync_pricing,      :boolean, default: false

    remove_column :hotels, :rates_synced_at
    add_column    :hotels, :last_availability_synced_at, :datetime
    add_column    :hotels, :last_pricing_synced_at,      :datetime
  end
end
