class AddColumnsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :street, :string
    add_column :users, :city, :string
    add_column :users, :zip_code, :string
    add_column :users, :country, :string
    add_column :users, :deleted, :boolean, default: false
    add_column :users, :company, :string
  end
end
