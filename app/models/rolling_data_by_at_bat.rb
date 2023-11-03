class RollingDataByAtBat < RollingData
  attr_accessor :data, :ab_count, :hit_count, :base_count, :ob_count, :avg, :obp, :slg, :ops

  def initialize(data_set)
    @data_set = data_set
    @ab_count, @hit_count, @base_count, @ob_count = 0, 0, 0, 0
  end

  def calc_totals
    @data_set.each do |at_bat|
      @ab_count += 1 if at_bat.count_at_bat?
      @hit_count += 1 if at_bat.hit?
      @base_count += at_bat.base_count
      @ob_count += at_bat.obp_value
    end

    @avg = @hit_count.to_f / @ab_count.to_f
    @obp = @ob_count.to_f / @ab_count.to_f
    @slg = @base_count.to_f / @ab_count.to_f
    @ops = @obp + @slg
  end

  def next_data_point(next_data_point)
    @data_set.drop(1) << next_data_point
  end

  def response_obj
    {
      avg: @avg,
      obp: @obp,
      slg: @slg,
      ops: @ops,
      time: @data_set.last.game_time
    }
  end
end
