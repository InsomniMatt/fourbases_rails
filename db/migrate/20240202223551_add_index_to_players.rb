class AddIndexToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_index :players, :name
    add_index :players, :position
    add_index :players, :team_id
  end
end
