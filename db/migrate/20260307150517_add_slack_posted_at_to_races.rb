class AddSlackPostedAtToRaces < ActiveRecord::Migration[8.0]
  def change
    add_column :races, :slack_posted_at, :datetime
  end
end
