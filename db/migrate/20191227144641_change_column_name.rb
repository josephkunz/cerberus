class ChangeColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :configs, :thumbnail_width, :screenshot_width
  end
end
