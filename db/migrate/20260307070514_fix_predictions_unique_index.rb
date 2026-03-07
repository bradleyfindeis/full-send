class FixPredictionsUniqueIndex < ActiveRecord::Migration[8.0]
  def change
    remove_index :predictions, name: :idx_predictions_unique_type, if_exists: true
    remove_index :predictions, name: :idx_predictions_unique_position, if_exists: true

    add_index :predictions, 
              [:user_id, :race_id, :session_type, :prediction_type, :position], 
              unique: true, 
              name: :idx_predictions_unique
  end
end
