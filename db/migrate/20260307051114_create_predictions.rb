class CreatePredictions < ActiveRecord::Migration[8.0]
  def change
    create_table :predictions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :race, null: false, foreign_key: true
      t.string :session_type, null: false
      t.integer :position
      t.references :driver, null: false, foreign_key: true
      t.integer :points_earned, default: 0, null: false
      t.string :prediction_type, null: false

      t.timestamps
    end
    add_index :predictions, [:user_id, :race_id, :session_type, :position], unique: true, name: "idx_predictions_unique_position"
    add_index :predictions, [:user_id, :race_id, :session_type, :prediction_type], unique: true, name: "idx_predictions_unique_type"
  end
end
