class CreateInfringements < ActiveRecord::Migration[5.2]
  def change
    create_table :infringements do |t|
      t.string :name
      t.string :url
      t.text :description
      t.integer :interval
      t.boolean :deleted, default: false
      t.references :case, foreign_key: true

      t.timestamps
    end
  end
end
