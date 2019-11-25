class CreateSnapshots < ActiveRecord::Migration[5.2]
  def change
    create_table :snapshots do |t|
      t.timestamp :time
      t.string :image_path
      t.string :web_path
      t.text :comment
      t.boolean :deleted, default: false
      t.references :infringement, foreign_key: true

      t.timestamps
    end
  end
end
