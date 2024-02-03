class AddTeamIdToAtBats < ActiveRecord::Migration[7.0]
  def change
    add_column :at_bats, :team_id, :integer
    add_index :at_bats, :team_id
    add_column :at_bats, :defense_team_id, :integer
    add_index :at_bats, :defense_team_id
  end
end
