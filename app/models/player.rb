class Player < ApplicationRecord
  include AtBatCollection

  belongs_to :team
  # delegate :games, to: :team
  has_many :batter_at_bats, foreign_key: :batter_id, class_name: "AtBat" do
    def by_team(team)
      where(:game_id => team.games.pluck(:id))
    end
  end
  has_many :pitched_at_bats, foreign_key: :pitcher_id, class_name: "AtBat"
  has_many :pitches, through: :batter_at_bats
  has_many :player_stats

  POSITION_ABBREVIATIONS = {"1" => "P", "2" => "C", "3" => "1B", "4" => "2B", "5" => "3B", "6" => "SS", "7" => "LF", "8" => "CF", "9" => "RF"}.freeze

  def games
    at_bats.includes(:game)
  end

  def at_bats
    pitcher? ? pitched_at_bats : batter_at_bats
  end

  def at_bat_count
    at_bats.count
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

  def portrait_url
    "https://img.mlbstatic.com/mlb-photos/image/upload/v1/people/#{id.to_s}/headshot/67/current";
  end

  def compare_to_baseline_player(baseline_player, startDate: nil, endDate: nil, groupCount: 100, groupType: "Games")
    baseline_range = baseline_player.range_by_query(comparing: true, startDate: startDate, endDate: endDate, groupCount: groupCount, groupType: groupType)
    player_range = range_by_query(comparing: true, startDate: startDate, endDate: endDate, groupCount: groupCount, groupType: groupType)


    player_range.each_with_index.inject(Hash.new{|h, k| h[k] = []}) do |map, pair|
      stat_item, index = pair
      map[:dates] << pair[:time]
      map[:avg]
      # binding.break
    end
    # comparison = compare_to_baseline(baseline_player)
    # result = {avg: [], dates: [], obp: [], ops: [], slg: []}
    # comparison.to_a.each do |el|
    #   result[:dates] << el[0]
    #   result[:avg] << el[1][:avg]
    #   result[:obp] << el[1][:obp]
    #   result[:ops] << el[1][:ops]
    #   result[:slg] << el[1][:slg]
    # end
    # result
  end

  def pitcher?
    position == "1"
  end

  def get_stats(year = 2023, force_sync = false)
    if force_sync || player_stats.where(:year => year).empty?
      PlayerStat.statcast_sync!(self)
    end
    player_stats.where(:year => year).last
  end

  def get_info
    {
      id: id,
      name: name,
      position: POSITION_ABBREVIATIONS[self.position],
      team_id: team.id,
      team_name: team.full_name,
    }
  end
end
