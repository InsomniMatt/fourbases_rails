class Player < ApplicationRecord
  belongs_to :team
  delegate :games, to: :team
  has_many :at_bats, foreign_key: :batter_id
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

  def avg
    (hit_count.to_f / stat_ab_count.to_f).round(3).to_s.sub(/^0/, '')
  end

  def obp
    (on_base_count.to_f / stat_ab_count.to_f).round(3).to_s.sub(/^0/, '')
  end

  def slg
    (slug_count.to_f / stat_ab_count.to_f).round(3).to_s.sub(/^0/, '')
  end

  def ops
    (obp.to_f + slg.to_f).to_s.to_s.sub(/^0/, '')
  end

  def abs_by_game

  end

  def stat_ab_count(manual_abs = [])
    abs = manual_abs.present? ? manual_abs : at_bats
    abs.filter {_1.count_at_bat?}.count
  end

  def hit_count(manual_abs = [])
    abs = manual_abs.present? ? manual_abs : at_bats
    abs.filter {_1.hit?}.count
  end

  def on_base_count(manual_abs = [])
    abs = manual_abs.present? ? manual_abs : at_bats
    abs.filter { _1.on_base? }.count
  end

  def slug_count(manual_abs = [])
    abs = manual_abs.present? ? manual_abs : at_bats
    abs.inject(0){|base_sum, at_bat| base_sum + at_bat.base_count }
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

  def portrait_url
    "https://img.mlbstatic.com/mlb-photos/image/upload/v1/people/#{id.to_s}/headshot/67/current";
  end

end
