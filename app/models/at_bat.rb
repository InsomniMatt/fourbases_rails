class AtBat < ApplicationRecord
  default_scope { order(game_id: :desc, at_bat_index: :asc)}

  belongs_to :game
  belongs_to :pitcher, class_name: "Player"
  belongs_to :batter, class_name: "Player"
  has_many :pitches

  delegate :game_time, to: :game

  RESULT_ARRAY =
      %w(single double triple home_run walk intent_walk hit_by_pitch field_error field_out force_out sac_fly sac_bunt
      grounded_into_double_play strikeout fielders_choice double_play catcher_interf fielders_choice_out
      sac_fly_double_play strikeout_double_play caught_stealing_2b caught_stealing_3b pickoff_error_3b
      pickoff_caught_stealing_2b pickoff_1b pickoff_2b pickoff_3b pickoff_caught_stealing_3b pickoff_caught_stealing_home
      caught_stealing_home other_out wild_pitch stolen_base_2b stolen_base_3b triple_play balk).freeze

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

  HIT_ARRAY = %w(single double triple home_run).freeze
  def hit?
    HIT_ARRAY.include? result
  end

  def hit_value
    hit? ? 1 : 0
  end

  OBP_ARRAY = %w(walk intent_walk hit_by_pitch).freeze
  def on_base?
    (OBP_ARRAY + HIT_ARRAY).include? result
  end

  def no_hit_on_base?
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

  OUT_ARRAY = %w(double_play field_error field_out fielders_choice fielders_choice_out force_out grounded_into_double_play strikeout strikeout_double_play triple_play).freeze
  def out?
    OUT_ARRAY.include? result
  end

  NO_AB_ARRAY = %w(walk intent_walk hit_by_pitch sac_fly sac_bunt sac_fly_double_play).freeze
  OTHER_COUNTED_AB = %w(catcher_interf).freeze
  AB_COUNT_ARRAY = HIT_ARRAY + OUT_ARRAY + OTHER_COUNTED_AB
  def count_at_bat?
    AB_COUNT_ARRAY.include? result
  end

  SAC_ABS = %w(sac_fly sac_fly_double_play).freeze
  def count_for_obp?
    (HIT_ARRAY + OBP_ARRAY + OUT_ARRAY + OTHER_COUNTED_AB + SAC_ABS).include? result
  end

  def stat_value_obj
    {
      avg: hit_value,
      obp: obp_value,
      slg: base_count,
      avg_weight: count_at_bat?,
      obp_weight: count_for_obp?,
    }
  end

  def + other_bat
    raise "AtBat can only be added to other AtBat" unless other_bat.class == AtBat
    AtBatRange.new([self, other_bat])
  end
end
