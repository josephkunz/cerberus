class RemoveViewportFromConfig < ActiveRecord::Migration[5.2]
  def change
    remove_column :configs, :viewport, :string
  end
end
