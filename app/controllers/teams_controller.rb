class TeamsController < ApplicationController
  before_action :set_player, only: %i[ show update destroy ]
  before_action :set_team, only: %i[ stats ]

  # GET /players
  def index
    players_response = Baseline.team_player_list(team_id_param)
    render status: :ok, json: players_response['roster'].map{ {name: _1['person']['fullName'], jersey_number: _1['jerseyNumber'], position: _1['position']['abbreviation'], player_id: _1['person']['id']}}
  end

  def stats
    info = {
      teamColors: @team.colors,
      teamName: @team.full_name,
      teamId: @team.id,
    }
    render status: :ok, json: {stats: @team.stats,rolling_stats: @team.rolling_stats(**stat_query_params.to_h.symbolize_keys), info: info, portrait: @team.logo_url}
  end

  # GET /players/1
  def show
    render json: @player
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_player
    @player = Player.find(params[:id])
  end

  def set_team
    @team = Team.find(team_id_param)
  end

  # Only allow a list of trusted parameters through.
  def player_params
    params.require(:player).permit(:name, :position, :team_id, :jersey_number, :throw_arm, :bat_arm)
  end

  def team_id_param
    params.require(:team_id)
  end

  def stat_query_params
    params.permit(:startDate, :endDate, :groupCount, :groupType, :baseline_id)
  end

end
