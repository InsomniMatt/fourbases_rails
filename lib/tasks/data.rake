namespace :data do
  desc "Import team data"
  task import_teams: :environment do
    Baseline.team_list.each do |team|
      Team.create!(id: team["id"], city: team["franchiseName"], name: team["clubName"], league: team["league"]["name"], division: team["division"]["name"])
      puts "Team created: #{team['clubName']}"
    end
  end

  desc "Import player data for each team"
  task import_players: :environment do
    all_players = Baseline.all_player_list
    player_object = all_players.map{Player.parse_api_response(_1)}.compact
    Player.create! player_object
  end

  desc "Import game data"
  task import_games: :environment do
    Baseline.schedule({"startDate" => "2023-03-30", "endDate" => "2023-09-01"}).each do |game|
      next if game["gamePk"] == 717421
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

  desc "Import at bat data"
  task import_at_bats: :environment do
    counter = 0
    Game.all.each do |game|
      next unless game.at_bats.empty?
      game.import_at_bats
      counter += 1
      puts "Imported game #{counter} at bats"
      sleep (0.5).second
    end
  end
end
