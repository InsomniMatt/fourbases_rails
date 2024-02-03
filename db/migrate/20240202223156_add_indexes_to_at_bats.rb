class AddIndexesToAtBats < ActiveRecord::Migration[7.0]
  def change
    add_index :at_bats, :outs
    add_index :at_bats, :inning
    add_index :at_bats, :result
  end
end
