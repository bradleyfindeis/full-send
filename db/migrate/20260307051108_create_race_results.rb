class CreateRaceResults < ActiveRecord::Migration[8.0]
  def change
    create_table :race_results do |t|
      t.references :race, null: false, foreign_key: true
      t.references :driver, null: false, foreign_key: true
      t.string :session_type, null: false
      t.integer :position, null: false
      t.boolean :fastest_lap, default: false, null: false

      t.timestamps
    end
    add_index :race_results, [:race_id, :session_type, :position], unique: true
    add_index :race_results, [:race_id, :session_type, :driver_id], unique: true
  end
end
