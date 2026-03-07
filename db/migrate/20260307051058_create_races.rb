class CreateRaces < ActiveRecord::Migration[8.0]
  def change
    create_table :races do |t|
      t.string :external_id, null: false
      t.string :name, null: false
      t.integer :round, null: false
      t.string :circuit_name
      t.string :circuit_country
      t.datetime :race_date
      t.datetime :quali_date
      t.datetime :sprint_date
      t.boolean :has_sprint, default: false, null: false
      t.boolean :cancelled, default: false, null: false
      t.references :season, null: false, foreign_key: true

      t.timestamps
    end
    add_index :races, :external_id, unique: true
    add_index :races, [:season_id, :round], unique: true
  end
end
