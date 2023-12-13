class Player < ApplicationRecord
  include AtBatCollection

  belongs_to :team
  delegate :games, to: :team
  has_many :at_bats, foreign_key: :batter_id do
    def by_team(team)
      where(:game_id => team.games.pluck(:id))
    end
  end
  has_many :pitched_at_bats, foreign_key: :pitcher_id, class_name: "AtBat"
  has_many :pitches, through: :at_bats

  def api_stats
    Baseline.player_stats(id, {"stats": "season"})
  end

  def self.parse_api_response(response)
    return nil if Player.find_by_id(response["id"]).present?

    player = {}
    player["id"] = response["id"]
    player["name"] = response["fullName"]
    player["position"] = response["primaryPosition"]["code"]
    player["team_id"] = response["currentTeam"]["id"]
    player["jersey_number"] = response["primaryNumber"]
    player["throw_arm"] = response["pitchHand"]["description"]
    player["bat_arm"] = response["batSide"]["description"]
    player
  end

  def self.find_or_fetch(id)
    record = Player.find_or_initialize_by(id: id)
    record.fetch_data if record.new_record?
  end

  def fetch_data
    player_info = Baseline.player_info(id)
    player_object = Player.parse_api_response(player_info)
    Player.create! player_object
  end

  def rolling_stats(size = 50, comparing = false)
    ranges = rolling_range(size, comparing)
    {
      dates: ranges.map { _2[:time] },
      avg: ranges.map { _2[:avg]},
      obp: ranges.map {_2[:obp]},
      slg: ranges.map { _2[:slg]},
      ops: ranges.map { _2[:ops]}
    }
  end

  def at_bats_by_game(manual_games = [])
    games = manual_games.present? ? manual_games : self.games.includes(:at_bats).where("at_bats.batter_id = ?", id).references(:at_bats)
    games.inject({}) do |result, game|
      result[game.id] = game.at_bats
      result
    end
  end

  def portrait_url
    "https://img.mlbstatic.com/mlb-photos/image/upload/v1/people/#{id.to_s}/headshot/67/current";
  end

  def compare_to_baseline_player(baseline_player)
    comparison = compare_to_baseline(baseline_player)
    result = {avg: [], dates: [], obp: [], ops: [], slg: []}
    comparison.to_a.each do |el|
      result[:dates] << el[0]
      result[:avg] << el[1][:avg]
      result[:obp] << el[1][:obp]
      result[:ops] << el[1][:ops]
      result[:slg] << el[1][:slg]
    end
    result
  end

end
