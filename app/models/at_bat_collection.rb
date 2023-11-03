class AtBatCollection
  attr_accessor :at_bats
  def initialize at_bats
    @at_bats = at_bats
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

  def rolling_range size = 50
    collections = []
    last_time = nil
    @at_bats.inject([]) do |arr, at_bat|
      arr << at_bat
      if arr.count > size
        arr.shift
      end
      unless at_bat.game_time == last_time
        if arr.count == size
          new_collection = AtBatCollection.new(arr).stat_obj
          last_time = new_collection[:time]
          collections << new_collection
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
      time: @at_bats.last.game.game_time.to_date.to_s
    }
  end
end