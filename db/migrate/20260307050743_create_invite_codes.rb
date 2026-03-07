class CreateInviteCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :invite_codes do |t|
      t.string :code, null: false
      t.integer :max_uses, default: 1, null: false
      t.integer :uses_count, default: 0, null: false
      t.datetime :expires_at
      t.references :created_by, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :invite_codes, :code, unique: true
  end
end
