class AtBatCollection
  attr_accessor :at_bats
  def initialize at_bats
    @at_bats = at_bats
  end

  def avg
    "%.3f" % avg_raw
  end

  def obp
    "%.3f" % obp_raw
  end

  def slg
    "%.3f" % slg_raw
  end

  def ops
    "%.3f" % ops_raw
  end

  def avg_raw
    (hit_count.to_f / stat_ab_count.to_f)
  end

  def obp_raw
    (on_base_count.to_f / stat_ab_count.to_f)
  end

  def slg_raw
    (slug_count.to_f / stat_ab_count.to_f)
  end

  def ops_raw
    (obp_raw + slg_raw)
  end

  def stat_ab_count
    @at_bats.filter {_1.count_at_bat?}.count
  end

  def hit_count
    @at_bats.filter {_1.hit?}.count
  end

  def on_base_count
    @at_bats.filter { _1.on_base? }.count
  end

  def slug_count
    @at_bats.inject(0){|base_sum, at_bat| base_sum + at_bat.base_count }
  end

  def at_bat_by_date
    @at_bats.inject({}) do |result, ab|
      date_string = ab.game_time.strftime("%m/%d/%Y")
      if result[date_string].present?
        result[date_string] << ab
      else
        result[date_string] = [ab]
      end
      result
    end
  end

  def last(num)
    AtBatCollection.new(@at_bats.last(num))
  end

  def + data
    if data.class == AtBat
      return AtBatCollection.new(self.at_bats + data)
    elsif data.class == AtBatCollection
      return AtBatCollection.new(self.at_bats + data.at_bats)
    else
      raise "Can only add AtBat or AtBatCollection to an AtBatCollection"
    end
  end

  def rolling_range size = 50, comparing = false
    collections = {}
    last_time = nil
    last_collection = nil
    @at_bats.inject([]) do |arr, at_bat|
      arr << at_bat
      if arr.count > size
        arr.shift
      end
      unless at_bat.game_time == last_time
        if arr.count == size
          if comparing && last_time.present?
            until (at_bat.game_time.to_date <= last_time)
              last_time = last_time.next
              collections[last_time] = last_collection
            end
          end
          last_collection = AtBatCollection.new(arr).stat_obj
          last_time = last_collection[:time]
          collections[last_time] = last_collection
        end
      end
      arr
    end
    collections
  end

  def stat_obj
    {
      avg: avg,
      obp: obp,
      slg: slg,
      ops: ops,
      time: @at_bats.last.game.game_time.to_date,
    }
  end

  def compare_to_baseline baseline_player
    baseline_rolling_range = baseline_player.rolling_range(50, true)
    cached_stat = nil
    rolling_range(50, true).inject({}) do |result, day_object|
      day = day_object.first
      day_value = day_object.last

      today_baseline = baseline_rolling_range[day] || cached_stat
      cached_stat = today_baseline
      if today_baseline.present?
        result[day] = day_value.inject({}) do |day_result, stat_object|
          stat = stat_object.first
          unless stat == :time
            stat_value = stat_object.last
            day_result[stat] = "%.3f" % (stat_value.to_f - today_baseline[stat].to_f)
          end
          day_result
        end
      end
      result
      # result[day] = {
      #   :avg => value[:avg].to_f - today_baseline[:avg]
      # }
    end
  end
end