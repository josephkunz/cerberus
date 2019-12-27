class AddScreenshotQualityToConfig < ActiveRecord::Migration[5.2]
  def change
    add_column :configs, :screenshot_quality, :integer
  end
end
