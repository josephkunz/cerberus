class CreateCases < ActiveRecord::Migration[5.2]
  def change
    create_table :cases do |t|
      t.string :name
      t.string :number
      t.text :description
      t.boolean :deleted, default: false
      t.boolean :archived, default: false
      t.references :user, foreign_key: true
      t.references :client, foreign_key: true

      t.timestamps
    end
  end
end
