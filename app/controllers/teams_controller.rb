class PlayersController < ApplicationController
  before_action :set_player, only: %i[ show update destroy ]

  # GET /players
  def index
    players_response = BaseballApi.team_player_list(team_id_param)
    puts players_response['roster'].map{ {name: _1['person']['fullName'], jersey_number: _1['jerseyNumber'], position: _1['position']['abbreviation'], player_id: _1['person']['id']}}
    byebug
    render status: :ok, json: players_response['roster'].map{ {name: _1['person']['fullName'], jersey_number: _1['jerseyNumber'], position: _1['position']['abbreviation'], player_id: _1['person']['id']}}
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

  # Only allow a list of trusted parameters through.
  def player_params
    params.require(:player).permit(:name, :position, :team_id, :jersey_number, :throw_arm, :bat_arm)
  end

  def team_id_param
    params.require(:team_id)
  end

end
