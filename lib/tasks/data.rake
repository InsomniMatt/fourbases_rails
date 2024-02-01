namespace :data do
  STAT_CAST_YEARS = (2014..2023).to_a.freeze

  desc "Import team data"
  task import_teams: :environment do
    Baseline.team_list["teams"].each do |team|
      Team.create!(id: team["id"], city: team["franchiseName"], name: team["clubName"], league: team["league"]["name"], division: team["division"]["name"])
      puts "Team created: #{team['clubName']}"
    end
  end

  desc "Import player data for each team"
  task import_players: :environment do
    STAT_CAST_YEARS.each do |year|
      year_players = Baseline.all_player_list("season": year)["people"]
      player_object = year_players.map{Player.parse_api_response(_1)}.compact
      Player.create! player_object
      puts "imported players for #{year}"
    end
  end


  desc "Import game data"
  task import_games: :environment do
    STAT_CAST_YEARS.each do |year|
      Baseline.schedule_year(year).each do |game|
        # Do not include All Star or Preseason games.
        next unless game["seriesDescription"] == "Regular Season"
        home_team = Team.find(game["teams"]["home"]["team"]["id"])
        away_team = Team.find(game["teams"]["away"]["team"]["id"])
        Game.find_or_create_by!({id: game["gamePk"], home_team_id: home_team.id, away_team_id: away_team.id}).tap do |game_model|
            game_model.home_score = game["teams"]["home"]["score"]
            game_model.away_score= game["teams"]["away"]["score"]
            game_model.game_time =  game["gameDate"]
        end.save!
        puts "Game created: #{game['description']}"
      end
    end
  end

  desc "Import at bat data"
  task import_at_bats: :environment do
    counter = 0
    Game.all.each do |game|
      next unless game.at_bats.empty?
      puts game.to_json
      game.import_at_bats
      counter += 1
      puts "Imported game #{counter} at bats"
      sleep (0.25).second
    end
  end
end
