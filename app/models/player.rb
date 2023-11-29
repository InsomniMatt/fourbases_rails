class Player < ApplicationRecord
  belongs_to :team
  delegate :games, to: :team
  has_many :at_bats, foreign_key: :batter_id
  has_many :pitched_at_bats, foreign_key: :pitcher_id, class_name: "AtBat"
  has_many :pitches, through: :at_bats

  attr_accessor :at_bat_collection

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

  def at_bat_collection
    return @at_bat_collection if @at_bat_collection.present?
    @at_bat_collection = AtBatCollection.new(at_bats)
  end

  def avg
    at_bat_collection.avg
  end

  def obp
    at_bat_collection.obp
  end

  def slg
    at_bat_collection.slg
  end

  def ops
    at_bat_collection.ops
  end

  def rolling_range size = 50, comparing = false
    at_bat_collection.rolling_range(size, comparing)
  end

  def rolling_stats
    ranges = rolling_range
    {
      dates: ranges.map { _2[:time] },
      avg: ranges.map { _2[:avg]},
      obp: ranges.map {_2[:obp]},
      slg: ranges.map { _2[:slg]},
      ops: ranges.map { _2[:ops]}
    }
  end

  def at_bat_by_date(manual_abs = [])
    abs = manual_abs.present? ? manual_abs : at_bats.includes(:game)
    abs.inject({}) do |result, ab|
      date_string = ab.game_time.strftime("%m/%d/%Y")
      if result[date_string].present?
        result[date_string] << ab
      else
        result[date_string] = [ab]
      end
      result
    end

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
    comparison = at_bat_collection.compare_to_baseline(baseline_player)
    result = {avg: [], dates: [], obp: [], ops: [], slg: []}
    comparison.to_a.each do |el|
      result[:dates] << el[0]
      result[:avg] << el[1][:avg]
      result[:obp] << el[1][:obp]
      result[:ops] << el[1][:ops]
      result[:slg] << el[1][:slg]
    end
    result
    # {
    #   dates: comparison.map { _2[:time] },
    #   avg: comparison.map { _2[:avg]},
    #   obp: comparison.map {_2[:obp]},
    #   slg: comparison.map { _2[:slg]},
    #   ops: comparison.map { _2[:ops]}
    # }
  end

end
