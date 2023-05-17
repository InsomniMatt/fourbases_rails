class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.string :name
      t.string :position
      t.integer :team_id
      t.integer :jersey_number
      t.string :throw_arm
      t.string :bat_arm

      t.timestamps
    end
  end
end
