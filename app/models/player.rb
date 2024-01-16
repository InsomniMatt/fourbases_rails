class Player < ApplicationRecord
  include AtBatCollection

  belongs_to :team
  delegate :games, to: :team
  has_many :batter_at_bats, foreign_key: :batter_id, class_name: "AtBat" do
    def by_team(team)
      where(:game_id => team.games.pluck(:id))
    end
  end
  has_many :pitched_at_bats, foreign_key: :pitcher_id, class_name: "AtBat"
  has_many :pitches, through: :at_bats

  def at_bats
    pitcher? ? pitched_at_bats : batter_at_bats
  end

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

  def at_bat_by_date_range(startDate, endDate)
    dated_at_bats = at_bats.includes(:game).where("games.game_time BETWEEN ? AND ?", DateTime.parse(startDate), DateTime.parse(endDate)).references(:games)
    AtBatRange.new(dated_at_bats)
  end

  def rolling_stats(comparing: false, startDate: nil, endDate: nil, groupCount: 100, groupType: "AtBats")
    if startDate.present? && endDate.present?
      at_bat_range = at_bat_by_date_range(startDate, endDate)
    else
      at_bat_range = self
    end

    case groupType
    when "At Bats"
      ranges = at_bat_range.rolling_range(groupCount.to_i, comparing)
    when "Games"
      ranges = at_bat_range.rolling_by_game(groupCount.to_i)
    when "Days"
      ranges = at_bat_range.rolling_by_day(groupCount.to_i)
    end


    {
      dates: ranges.map { _1[:time] },
      avg: ranges.map { _1[:avg]},
      obp: ranges.map {_1[:obp]},
      slg: ranges.map { _1[:slg]},
      ops: ranges.map { _1[:ops]}
    }
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

  def pitcher?
    position == "1"
  end
end
