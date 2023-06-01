class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.references :home_team, foreign_key: {to_table: :teams}, index: true
      t.references :away_team, foreign_key: {to_table: :teams}, index: true
      t.integer :home_score
      t.integer :away_score
      t.datetime :game_time

      t.timestamps
    end
  end
end
