class CreateSeasonPredictions < ActiveRecord::Migration[8.0]
  def change
    create_table :season_predictions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :season, null: false, foreign_key: true
      t.references :drivers_champion, foreign_key: { to_table: :drivers }
      t.references :constructors_champion, foreign_key: { to_table: :teams }
      t.integer :points_earned, default: 0, null: false
      t.datetime :locked_at

      t.timestamps
    end
    add_index :season_predictions, [:user_id, :season_id], unique: true
  end
end
