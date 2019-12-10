class CreateConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :configs do |t|
      t.boolean :fullpage
      t.integer :thumbnail_width
      t.string :viewport

      t.timestamps
    end
  end
end
