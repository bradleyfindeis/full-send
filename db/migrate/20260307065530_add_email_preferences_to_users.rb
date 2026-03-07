class AddEmailPreferencesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :email_reminders, :boolean, default: true, null: false
  end
end
