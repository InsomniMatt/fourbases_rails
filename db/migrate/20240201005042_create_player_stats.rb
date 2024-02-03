class CreatePlayerStats < ActiveRecord::Migration[7.0]
  def change
    create_table :player_stats do |t|
      t.references :player
      t.string  :avg
      t.string  :obp
      t.string  :slg
      t.string  :ops
      t.integer :hits
      t.integer :doubles
      t.integer :triples
      t.integer :home_runs
      t.integer :walks
      t.integer :strikeouts
      t.integer :runs
      t.integer :games
      t.integer :at_bats
      t.integer :rbi
      t.integer :stolen_bases
      t.integer :caught_stealing
      t.integer :plate_appearances
      t.integer :sac_fly
      t.integer :sacrifices
      t.integer :hbp
      t.integer :gidp
      t.integer :year

      t.timestamps
    end
  end
end
