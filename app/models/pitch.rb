class Pitch < ApplicationRecord
  belongs_to :at_bat

  CHANGEUP = 1.freeze
  CURVEBALL = 2.freeze
  CUTTER = 3.freeze
  EEPHUS = 4.freeze
  FORKBALL = 5.freeze
  FOUR_SEAM_FASTBALL = 6.freeze
  KNUCKLEBALL = 7.freeze
  KNUCKLECURVE = 8.freeze
  SCREWBALL = 9.freeze
  SINKER = 10.freeze
  SLIDER = 11.freeze
  SLURVE = 12.freeze
  SPLITTER = 13.freeze
  SWEEPER = 14.freeze

  def self.parse_api_response(pitch)
    Pitch.new({
      :pitch_type => pitch["details"]["type"]["code"],
      :velocity => pitch["pitchData"]["startSpeed"],
      :ball_count => pitch["count"]["balls"],
      :strike_count => pitch["count"]["strikes"],
    })
  end
end

