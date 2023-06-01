namespace :data do
  desc "Import team data"
  task import_teams: :environment do
    BaseballApi.team_list.each do |team|
      Team.create!(id: team["id"], city: team["franchiseName"], name: team["clubName"], league: team["league"]["name"], division: team["division"]["name"])
      puts "Team created: #{team['clubName']}"
    end
  end

  desc "Import player data for each team"
  task import_players: :environment do
    Team.all.each do |team|
      team.roster.each do |player|
        Player.create!(id: player["person"]["id"], name: player["person"]["fullName"], position: player["position"]["code"], team: team, jersey_number: player["jerseyNumber"])
        puts "Player created: #{player["person"]["fullName"]}"
      end
    end
  end

  desc "Import game data"
  task import_games: :environment do
    BaseballApi.schedule.each do |game|
      home_team = Team.find(game["teams"]["home"]["team"]["id"])
      away_team = Team.find(game["teams"]["away"]["team"]["id"])
      Game.upsert({id: game["gamePk"], home_team_id: home_team.id, away_team_id: away_team.id, home_score: game["teams"]["home"]["score"], away_score: game["teams"]["away"]["score"], game_time: game["gameDate"]})
      puts "Game created: #{game['description']}"
    end
  end

  desc "Import game at bats"
  task import_game_at_bats: :environment do
    Game.first
  end

end
