class AddPreferencesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :time_format, :string, default: "24h", null: false
    add_column :users, :theme, :string, default: "default", null: false
  end
end
