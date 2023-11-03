class AtBat < ApplicationRecord
  default_scope { order(game_id: :desc, at_bat_index: :asc)}

  belongs_to :game
  belongs_to :pitcher, class_name: "Player"
  belongs_to :batter, class_name: "Player"
  has_many :pitches

  delegate :game_time, to: :game

  HIT_ARRAY = %w(single double triple home_run).freeze
  RESULT_ARRAY = %w(single double triple home_run walk hit_by_pitch field_error field_out force_out sac_fly sac_bunt grounded_into_double_play strikeout fielders_choice double_play).freeze

  scope :hits, -> { where(result: HIT_ARRAY)}
  scope :last_two_weeks, -> { includes(:game).where('games.game_time BETWEEN ? and ?', 2.weeks.ago, Time.now).references(:game)}


  RESULT_ARRAY.each do |method|
    define_method "#{method}?" do
      self.result == method
    end
  end

  def self.parse_api_response(at_bat, game_id)
    pitch_data = at_bat["playEvents"]
    pitches = pitch_data.map do |pitch|
      next if pitch["details"]["event"] == "Game Advisory" || pitch.dig("details", "type","code").nil?
      Pitch.parse_api_response(pitch)
    end
    batter = Player.find(at_bat["matchup"]["batter"]["id"])
    pitcher = Player.find(at_bat["matchup"]["pitcher"]["id"])
    {
        :pitcher => pitcher,
        :batter => batter,
        :game_id => game_id,
        :outs => pitch_data.first["count"]["outs"].to_i,
        :inning => at_bat["about"]["inning"],
        :inning_half => at_bat["about"]["halfInning"],
        :result => at_bat["result"]["eventType"].to_sym,
        :pitches => pitches.compact,
        :at_bat_index => at_bat["atBatIndex"],
    }
  end

  def hit?
    HIT_ARRAY.include? result
  end

  OBP_ARRAY = ["walk", "hit_by_pitch"] + HIT_ARRAY
  def on_base?
    OBP_ARRAY.include? result
  end

  def obp_value
    on_base? ? 1 : 0
  end

  BASE_COUNT_MAP = {:single =>  1, :double => 2, :triple => 3, :home_run => 4 }.with_indifferent_access.freeze
  def base_count
    return 0 unless hit?
    BASE_COUNT_MAP[result]
  end

  OUT_ARRAY = ["field_out", "grounded_into_double_play", "force_out", "strikeout"].freeze
  def out?
    OUT_ARRAY.include? result
  end

  NO_AB_ARRAY = %w(walk hit_by_pitch sac_fly sac_bunt)
  def count_at_bat?
    !NO_AB_ARRAY.include? result
  end

  def + other_bat
    raise "AtBat can only be added to other AtBat" unless other_bat.class == AtBat
    AtBatCollection.new([self, other_bat])
  end
end
