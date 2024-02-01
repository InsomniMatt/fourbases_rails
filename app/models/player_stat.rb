class PlayerStat < ApplicationRecord
  belongs_to :player

  def self.statcast_sync!(player)
    response = player.api_stats
    if response["stats"].empty?
      stat_obj = PlayerStat.blank_object(player.id)
    else
      stats = response["stats"].first["splits"].first["stat"]

      stat_obj = {
        :player_id => player.id,
        :avg => stats["avg"],
        :obp => stats["obp"],
        :slg => stats["slg"],
        :ops => stats["ops"],
        :hits => stats["hits"],
        :doubles => stats["doubles"],
        :triples => stats["triples"],
        :home_runs => stats["homeRuns"],
        :walks => stats["baseOnBalls"],
        :strikeouts => stats["strikeOuts"],
        :runs => stats["runs"],
        :games => stats["gamesPlayed"],
        :at_bats => stats["atBats"],
        :rbi => stats["rbi"],
        :stolen_bases => stats["stolenBases"],
        :caught_stealing => stats["caughtStealing"],
        :plate_appearances => stats["plateAppearances"],
        :sac_fly => stats["sacFlies"],
        :sacrifices => stats["sacBunts"],
        :hbp => stats["hitByPitch"],
        :gidp => stats["groundIntoDoublePlay"],
        :year => response["stats"].first["splits"].first["season"]
      }
    end

    PlayerStat.upsert(stat_obj)
  end

  def self.blank_object(player_id)
    {
      :player_id => player_id,
      :avg => ".000",
      :obp => ".000",
      :slg => ".000",
      :ops => ".000",
      :hits => 0,
      :doubles => 0,
      :triples => 0,
      :home_runs => 0,
      :walks => 0,
      :strikeouts => 0,
      :runs => 0,
      :games => 0,
      :at_bats => 0,
      :rbi => 0,
      :stolen_bases => 0,
      :caught_stealing => 0,
      :plate_appearances => 0,
      :sac_fly => 0,
      :sacrifices => 0,
      :hbp => 0,
      :gidp => 0,
      :year => 2023
    }
  end
end
