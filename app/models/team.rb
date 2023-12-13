class Team < ApplicationRecord
  has_many :players
  has_many :home_games, class_name: "Game", foreign_key: :home_team_id
  has_many :home_at_bats, through: :home_games
  has_many :away_games, class_name: "Game", foreign_key: :away_team_id
  has_many :away_at_bats, through: :away_games


  COLORS = {
      108 => {
        # Angels
        primary: "#862633",
        secondary: "#C4CED4",
      },
      109 => {
        # Diamondbacks
        primary: "#A71930",
        secondary: "#FFFFFF",
      },
      110 => {
        # Orioles
        primary: "#DF4601",
        secondary: "#FFFFFF",
      },
      111 => {
        # Red Sox
        primary: "#BD3039",
        secondary: "#0C2340",
      },
      112 => {
        # Cubs
        primary: "#0E3386",
        secondary: "#CC3433",
      },
      113 => {
        # Reds
        primary: "#C6011F",
        secondary: "#FFFFFF",
      },
      114 => {
        # Guardians
        primary: "#E50022",
        secondary: "#00385D",
      },
      # Rockies
      115 => {
        primary: "#333366",
        secondary: "#C4CED4",
      },
      # Tigers
      116 => {
        primary: "#0C2340",
        secondary: "#FA4616",
      },
      # Astros
      117 => {
        primary: "#002D62",
        secondary: "#EB6E1F",
      },
      # Royals
      118 => {
        primary: "#004687",
        secondary: "#BD9B60",
      },
      # Dodgers
      119 => {
        primary: "#005A9C",
        secondary: "#A5ACAF",
      },
      # Nationals
      120 => {
        primary: "#AB0003",
        secondary: "#14225A",
      },
      # Mets
      121 => {
        primary: "#002D72",
        secondary: "#FF5910",
      },
      # Athletics
      133 => {
        primary: "#003831",
        secondary: "#EFB21E",
      },
      # Pirates
      134 => {
        primary: "#27251F",
        secondary: "#FDB827",
      },
      # Padres
      135 => {
        primary: "#2F241D",
        secondary: "#FFC425",
      },
      # Mariners
      136 => {
        primary: "#0C2C56",
        secondary: "#005C5C",
      },
      # Giants
      137 => {
        primary: "#FD5A1E",
        secondary: "#27251F",
      },
      # Cardinals
      138 => {
        primary: "#C41E3A",
        secondary: "#0C2340",
      },
      # Rays
      139 => {
        primary: "#092C5C",
        secondary: "#8FBCE6",
      },
      # Rangers
      140 => {
        primary: "#C0111F",
        secondary: "#003278",
      },
      # Blue Jays
      141 => {
        primary: "#134A8E",
        secondary: "#1D2D5C",
      },
      # Twins
      142 => {
        primary: "#002B5C",
        secondary: "#D31145",
      },
      # Phillies
      143 => {
        primary: "#E81828",
        secondary: "#002D72",
      },
      # Braves
      144 => {
        primary: "#CE1141",
        secondary: "#13274F",
      },
      # White Sox
      145 => {
        primary: "#27251F",
        secondary: "#C4CED4",
      },
      # Marlins
      146 => {
        primary: "#00A3E0",
        secondary: "#41748D",
      },
      # Yankees
      147 => {
        primary: "#0C2340",
        secondary: "#C4CED3",
      },
      # Brewers
      158 => {
        primary: "#12284B",
        secondary: "#FFC52F",
      },
  }

  def games
    home_games.or(away_games)
  end

  def roster
    Baseline.team_player_list(id)["roster"]
  end

  def logo_url
    "https://www.mlbstatic.com/team-logos/team-cap-on-dark/#{id}.svg"
  end

  def colors
    COLORS[id]
  end

  def at_bats
    away_at_bats.union(home_at_bats)
  end
end
