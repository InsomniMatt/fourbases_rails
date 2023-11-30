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
    stats = Baseline.player_stats(@player.id)["stats"].first
    info = stats ? stats["group"] : {}
    info["playerName"] = @player.name
    info["playerId"] = @player.id
    info["teamLogo"] = @player.team.logo_url
    info["teamColors"] = @player.team.colors
    render json: {info: info, stats: stats ? stats["splits"].first["stat"] : [], portrait: player_portrait_url}
  end

  def compare_to_baseline
    baseline_player = Player.find(baseline_id_param)
    render json: {comparison: @player.compare_to_baseline_player(baseline_player)}
  end

  def search
    players = Player.where("name LIKE ?", "%#{params['search']}%")
    render status: :ok, json: {players: players}
  end

  def rolling_stats
    render status: :ok, json: {rolling_stats: @player.rolling_stats}
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_player
    @player = Player.find(player_id_param)
  end

  # Only allow a list of trusted parameters through.
  def player_id_param
    params.require(:player_id).to_i
  end

  def baseline_id_param
    params.require(:baseline_id).to_i
  end

  def team_id_param
    params.require(:team_id).to_i
  end

end
