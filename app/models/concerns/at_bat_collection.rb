module AtBatCollection
  extend ActiveSupport::Concern

  included do
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
      (on_base_count.to_f / ab_count_for_obp.to_f)
    end

    def slg_raw
      (slug_count.to_f / stat_ab_count.to_f)
    end

    def ops_raw
      (obp_raw + slg_raw)
    end

    def stat_ab_count
      at_bats.filter {_1.count_at_bat?}.count
    end

    def ab_count_for_obp
      at_bats.filter {_1.count_for_obp?}.count
    end

    def counted_bats
      at_bats.filter {_1.count_at_bat?}
    end

    def hit_count
      at_bats.filter {_1.hit?}.count
    end

    def on_base_count
      at_bats.filter { _1.on_base? }.count
    end

    def on_base_no_hit_count
      at_bats.filter { _1.no_hit_on_base? }.count
    end

    def on_base_no_hit_bats
      at_bats.filter { _1.no_hit_on_base? }
    end

    def on_base
      at_bats.filter { _1.on_base? }
    end

    def hits
      at_bats.filter {_1.hit?}
    end

    def slug_count
      at_bats.inject(0){|base_sum, at_bat| base_sum + at_bat.base_count }
    end

    def at_bat_by_date
      at_bats.includes(:game).inject({}) do |result, ab|
        date_string = ab.game_time.strftime("%m/%d/%Y")
        if result[date_string].present?
          result[date_string] << ab
        else
          result[date_string] = [ab]
        end
        result
      end
    end

    def count(result)
      at_bats.filter { _1.result == result}.count
    end

    def last(num)
      AtBatRange.new(at_bats.last(num))
    end

    def rolling_range size = 100, comparing = false
      ranges = {}
      last_time = nil
      last_range = nil
      at_bats.includes(:game).inject([]) do |arr, at_bat|
        arr << at_bat
        if arr.count > size
          arr.shift
        end
        unless at_bat.game_time == last_time
          if arr.count == size
            if comparing && last_time.present?
              until (at_bat.game_time.to_date <= last_time)
                last_time = last_time.next
                ranges[last_time] = last_range
              end
            end
            last_range = AtBatRange.new(arr).stat_obj
            last_time = last_range[:time]
            ranges[last_time] = last_range
          end
        end
        arr
      end
      ranges.values
    end

    def stat_obj
      {
        avg: avg,
        obp: obp,
        slg: slg,
        ops: ops,
        weight: at_bats.count,
        time: at_bats.last.game.game_time.to_date,
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
      end
    end

    # Work in progress
    # Calculating rolling stats with only a single pass through of the at bats
    def rolling(size = 100)
      removed_el = nil
      results = []

      at_bats.includes(:game).inject([]) do |arr, at_bat|
        arr << at_bat
        removed_el = arr.shift if arr.count > size

        if arr.count == size

        end
      end
    end

    def ranges_by_at_bat
      at_bats.map do |ab|
        AtBatRange.new([ab])
      end
    end

    def at_bats_by_game
      with_games = at_bats.includes(:game)
      with_games.inject(Hash.new{|h, k| h[k] = []}) do |map, at_bat|
        map[at_bat.game_id] << at_bat
        map
      end
    end

    def game_ids
      at_bats.pluck(:game_id).uniq
    end

    def rolling_by_game(n = 10)
      game_map = at_bats_by_game
      result_map = []
      game_ids.each_cons(n) do |id_array|
        ab_range = id_array.inject([]) do |ab_array, game_id|
          ab_array + game_map[game_id]
        end
        result_map << AtBatRange.new(ab_range)
      end
      result_map.map(&:stat_obj)
    end

    def rolling_by_day(n = 14)
      ab_date_map = at_bats.group_by(&:group_by_day)
      result_map = []
      ab_date_map.keys.each_cons(n) do |date_array|
        ab_range = date_array.inject([]) do |ab_array, date|
          ab_array + ab_date_map[date]
        end
        result_map << AtBatRange.new(ab_range)
      end
      result_map.map(&:stat_obj)
    end

    def at_bat_by_date_range(startDate, endDate)
      dated_at_bats = at_bats.includes(:game).where("games.game_time BETWEEN ? AND ?", DateTime.parse(startDate), DateTime.parse(endDate)).order("at_bats.id").references(:games)
      AtBatRange.new(dated_at_bats)
    end

    def range_by_query(ranges, comparing: false, groupCount: 100, groupType: "At Bats")
      case groupType
      when "At Bats"
        ranges = ranges.rolling_range(groupCount.to_i, comparing)
      when "Games"
        ranges = ranges.rolling_by_game(groupCount.to_i)
      when "Days"
        ranges = ranges.rolling_by_day(groupCount.to_i)
      end
      ranges
    end

    def base_stats(at_bat_range)
      {
        atBats: at_bat_range.stat_ab_count,
        hits: at_bat_range.hit_count,
        doubles: at_bat_range.count("double"),
        triples: at_bat_range.count("triple"),
        homeRuns: at_bat_range.count("home_run"),
        avg: at_bat_range.avg,
        obp: at_bat_range.obp,
        ops: at_bat_range.ops,
      }
    end

    def stats(comparing: false, startDate: nil, endDate: nil, groupCount: 100, groupType: "At Bats")
      if startDate.present? && endDate.present?
        at_bat_range = at_bat_by_date_range(startDate, endDate)
      else
        at_bat_range = self
      end


      range_set = range_by_query(at_bat_range, comparing: comparing, groupCount: groupCount, groupType: groupType)

      {
        "rolling_stats" => {
            dates: range_set.map { _1[:time] },
            avg: range_set.map { _1[:avg]},
            obp: range_set.map {_1[:obp]},
            slg: range_set.map { _1[:slg]},
            ops: range_set.map { _1[:ops]}
        },
        "stats" => base_stats(at_bat_range),
      }
    end
  end
end