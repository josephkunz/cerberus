class AddColumnsToConfig < ActiveRecord::Migration[5.2]
  def change
    add_column :configs, :window_width, :integer
    add_column :configs, :window_height, :integer
  end
end
