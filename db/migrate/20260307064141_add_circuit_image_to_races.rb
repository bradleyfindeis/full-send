class AddCircuitImageToRaces < ActiveRecord::Migration[8.0]
  def change
    add_column :races, :circuit_image_url, :string
  end
end
