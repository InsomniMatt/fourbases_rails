class Game < ApplicationRecord
  belongs_to :home_team, class_name: "Team"
  belongs_to :away_team, class_name: "Team"
  has_many :at_bats

  scope :completed, -> { where("game_time < ?", DateTime.now) }

  def at_bats
    return [] unless game_completed?
    if at_bats.empty?
      import_at_bats
    end
    at_bats
  end

  def game_completed?
    game_time < DateTime.now
  end

  def import_at_bats
    at_bats.delete_all
    BaseballApi.game_at_bats(id).each do |at_bat|
      AtBat.create!({
                      :pitcher_id => at_bat["matchup"]["pitcher"]["id"],
                      :batter_id => at_bat["matchup"]["batter"]["id"],
                    })
    end

  end

end
