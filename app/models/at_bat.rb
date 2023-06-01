class AtBat < ApplicationRecord
  belongs_to :game
  has_many :pitches
end
