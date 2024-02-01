class Game < ApplicationRecord
  default_scope {order(:game_time)}


  belongs_to :home_team, class_name: "Team"
  belongs_to :away_team, class_name: "Team"
  has_many :away_at_bats, -> { where inning_half: "top"}, class_name: "AtBat"
  has_many :home_at_bats, -> { where inning_half: "bottom"}, class_name: "AtBat"
  has_many :at_bats do
    def by_player(player_id)
      where(:batter_id => player_id)
    end
  end

  scope :completed, -> { where("game_time < ?", DateTime.now) }

  def game_completed?
    game_time < DateTime.now
  end

  def import_at_bats
    at_bats.delete_all
    new_at_bats = Baseline.game_at_bats(id).map do |at_bat|
      next unless at_bat.dig("result", "eventType").present?

      AtBat.parse_api_response(at_bat, id)
    end
    AtBat.create!(new_at_bats.compact)
  end

end
