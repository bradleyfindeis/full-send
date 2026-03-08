class AddResultsSyncFieldsToRaces < ActiveRecord::Migration[8.0]
  def change
    add_column :races, :last_results_sync_at, :datetime
    add_column :races, :results_finalized, :boolean, default: false, null: false
  end
end
