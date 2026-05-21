class RenameSyncRatesToSyncRate < ActiveRecord::Migration[8.1]
  def change
    rename_column :hotels, :sync_rates, :sync_rate
  end
end
