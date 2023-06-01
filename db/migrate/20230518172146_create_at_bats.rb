class CreateAtBats < ActiveRecord::Migration[7.0]
  def change
    create_table :at_bats do |t|
      t.references :pitcher, foreign_key: {to_table: :players}, index: true
      t.references :batter, foreign_key: {to_table: :players}, index: true
      t.references :game, foreign_key: {to_table: :games}, index: true
      t.boolean :runner_first
      t.boolean :runner_second
      t.boolean :runner_third
      t.integer :outs
      t.integer :inning
      t.string :inning_half
      t.string :result

      t.timestamps
    end
  end
end
