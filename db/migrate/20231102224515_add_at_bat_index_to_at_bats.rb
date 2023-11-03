class AddAtBatIndexToAtBats < ActiveRecord::Migration[7.0]
  def change
    add_column :at_bats, :at_bat_index, :integer
  end
end
