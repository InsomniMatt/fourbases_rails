require 'httparty'

class PlayerApi < ApplicationRecord
  BASE_URL = "https://statsapi.mlb.com/api/v1"


  def self.team_player_list
    HTTParty.get(BASE_URL + "/teams/136/roster")
  end
end
