class CreateDrivers < ActiveRecord::Migration[8.0]
  def change
    create_table :drivers do |t|
      t.string :external_id, null: false
      t.string :name, null: false
      t.string :code
      t.integer :number
      t.references :team, foreign_key: true

      t.timestamps
    end
    add_index :drivers, :external_id, unique: true
  end
end
