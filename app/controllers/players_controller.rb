class PlayersController < ApplicationController
  before_action :set_player, :only => [:show, :stats, :rolling_stats, :compare_to_baseline]

  # GET /players
  def index
    players_response = Baseline.team_player_list(team_id_param)

    render status: :ok, json: players_response['roster'].map{ {name: _1['person']['fullName'], jersey_number: _1['jerseyNumber'], position: _1['position']['abbreviation'], id: _1['person']['id']}}
  end

  # GET /players/1
  def show
    render json: @player
  end

  def trending
    leaderboard = Baseline.stats(:season => 2023, :stats => "season", :group => "hitting", :sortStat => "OPS").call_api["stats"].first["splits"]
    leaderboard.map! do |player|
      {
          info: {
              id: player["player"]["id"],
              name: player["player"]["fullName"],
              position: player["position"]["abbreviation"],
              team_id: player["team"]["id"],
              team_name: Team.find(player["team"]["id"]).full_name,
          },
          stats: {
            games: player["stat"]["gamesPlayed"],
            atBats: player["stat"]["atBats"],
            runs: player["stat"]["runs"],
            doubles: player["stat"]["doubles"],
            triples: player["stat"]["triples"],
            home_runs: player["stat"]["homeRuns"],
            hits: player["stat"]["hits"],
            avg: player["stat"]["avg"],
            obp: player["stat"]["obp"],
            slg: player["stat"]["slg"],
            ops: player["stat"]["ops"],
            rbi: player["stat"]["rbi"]
          }
      }
    end
    render status: :ok, json: {players: leaderboard, teams: []}
  end

  # GET /player/:id/stats
  def stats
    player_portrait_url = @player.portrait_url
    api_stats = Baseline.player_stats(@player.id)["stats"].first
    info = api_stats.present? ? api_stats["group"] : {}
    info = info.merge({"playerName": @player.name, "id": @player.id, "teamLogo": @player.team.logo_url, "teamColors": @player.team.colors})
    # baseline_comparison = baseline_opt_param.present? ? @player.compare_to_baseline_player(Player.find(baseline_opt_param)) : false
    stats = @player.stats(**stat_query_params.to_h.symbolize_keys)
    render json: stats.merge({info: info, portrait: player_portrait_url})
  end

  def compare_to_baseline
    baseline_player = Player.find(baseline_id_param)
    render json: {comparison: @player.compare_to_baseline_player(baseline_player)}
  end

  def search
    players = Player.where("lower(name) LIKE ?", "%#{search_param.downcase}%").includes(:player_stats).sort_by(&:at_bat_count).reverse!
    teams = Team.where("city LIKE ? OR name LIKE ?", "%#{search_param}%", "%#{search_param}%")

    team_hashes = teams.inject([]) do |results, team|
      players = players | team.players
      results << team.get_info
    end

    player_array = players.map do |player|
      {info: player.get_info, stats: player.player_stats.first || player.get_stats}
    end
    render status: :ok, json: {players: player_array, teams: team_hashes}
  end

  def rolling_stats
    render status: :ok, json: {rolling_stats: @player.rolling_stats}
  end

  private
  def set_player
    @player = Player.find(player_id_param)
  end

  def player_id_param
    params.require(:player_id).to_i
  end

  def baseline_id_param
    params.require(:baseline_id).to_i
  end

  def team_id_param
    params.require(:team_id).to_i
  end

  def search_param
    params.require(:query)
  end

  def baseline_opt_param
    params.permit(:baseline_id)["baseline_id"]
  end

  def stat_query_params
    params.permit(:startDate, :endDate, :groupCount, :groupType, :baseline_id)
  end

end
