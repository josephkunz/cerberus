class AddInfringementIdToEvents < ActiveRecord::Migration[5.2]
  def change
    add_reference :events, :infringement, foreign_key: true
  end
end
