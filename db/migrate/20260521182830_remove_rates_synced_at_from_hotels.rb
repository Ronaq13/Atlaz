class RemoveRatesSyncedAtFromHotels < ActiveRecord::Migration[8.1]
  def up
    remove_column :hotels, :rates_synced_at
  end

  def down
    add_column :hotels, :rates_synced_at, :datetime
  end
end
