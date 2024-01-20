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

  # GET /player/:id/stats
  def stats
    player_portrait_url = @player.portrait_url
    api_stats = Baseline.player_stats(@player.id)["stats"].first
    info = api_stats ? api_stats["group"] : {}
    info = info.merge({"playerName": @player.name, "playerId": @player.id, "teamLogo": @player.team.logo_url, "teamColors": @player.team.colors})
    baseline_comparison = baseline_opt_param.present? ? @player.compare_to_baseline_player(Player.find(baseline_opt_param)) : false
    render json: {info: info, stats: api_stats["splits"].first["stat"], portrait: player_portrait_url, rolling_stats: @player.rolling_stats(**stat_query_params.to_h.symbolize_keys), comparison_stats: baseline_comparison}
  end

  def compare_to_baseline
    baseline_player = Player.find(baseline_id_param)
    render json: {comparison: @player.compare_to_baseline_player(baseline_player)}
  end

  def search
    players = Player.where("lower(name) LIKE ?", "%#{search_param.downcase}%")
    teams = Team.where("city LIKE ? OR name LIKE ?", "%#{search_param}%", "%#{search_param}%")

    team_hashes = teams.inject([]) do |results, team|
      players = players | team.players
      results << {name: "#{team.city} #{team.name}", id: team.id, logo_url: team.logo_url, type: "team" }
    end
    render status: :ok, json: {players: players.sort_by(&:at_bat_count).reverse!, teams: team_hashes}
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
