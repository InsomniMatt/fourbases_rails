class Game < ApplicationRecord
  default_scope {order(:game_time)}


  belongs_to :home_team, class_name: "Team"
  belongs_to :away_team, class_name: "Team"
  has_many :at_bats

  scope :completed, -> { where("game_time < ?", DateTime.now) }

  def game_completed?
    game_time < DateTime.now
  end

  def import_at_bats
    at_bats.delete_all
    new_at_bats = Baseline.game_at_bats(id).map do |at_bat|
      AtBat.parse_api_response(at_bat, id)
    end
    AtBat.create!(new_at_bats)

  end

end
