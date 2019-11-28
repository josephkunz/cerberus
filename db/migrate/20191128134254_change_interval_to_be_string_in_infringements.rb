class ChangeIntervalToBeStringInInfringements < ActiveRecord::Migration[5.2]
  def change
    change_column :infringements, :interval, :string
  end
end
