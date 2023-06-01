class CreatePitches < ActiveRecord::Migration[7.0]
  def change
    create_table :pitches do |t|
      t.integer :pitch_type
      t.float   :velocity
      t.integer :ball_count
      t.integer :strike_count
      t.float   :x_location
      t.float   :y_location
      t.float   :x_movement
      t.float   :y_movement
      t.references :at_bat, foreign_key: true, index: true

      t.timestamps
    end
  end
end
