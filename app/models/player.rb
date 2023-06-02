class Player < ApplicationRecord
  belongs_to :team

  def api_stats
    BaseballApi.player_stats(id, {"stats": "season"})
  end
end
