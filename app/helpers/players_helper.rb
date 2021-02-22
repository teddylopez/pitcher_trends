module PlayersHelper

  def style_pitch_count_warning(line)
    if line.stats['number_of_pitches'].to_i < 95
      return "low-risk"
    elsif line.stats['number_of_pitches'].to_i > 90 && line.stats['number_of_pitches'].to_i < 109
      return "medium-risk"
    else
      return "high-risk"
    end
  end

  def abbrev_team(team)
    teams = {
      "Arizona Diamondbacks" => "ARI",
      "Atlanta Braves" => "ATL",
      "Baltimore Orioles" => "BAL",
      "Boston Red Sox" => "BOS",
      "Chicago Cubs" => "CHC",
      "Chicago White Sox" => "CWS",
      "Cincinnati Reds" => "CIN",
      "Cleveland Indians" => "CLE",
      "Colorado Rockies" => "COL",
      "Detroit Tigers" => "DET",
      "Houston Astros" => "HOU",
      "Los Angeles Angels" => "LAA",
      "Los Angeles Dodgers" => "LAD",
      "Kansas City Royals" => "KC",
      "Miami Marlins" => "MIA",
      "Milwaukee Brewers" => "MIL",
      "Minnesota Twins" => "MIN",
      "New York Mets" => "NYM",
      "New York Yankees" => "NYY",
      "Philadelphia Phillies" => "PHI",
      "Oakland Athletics" => "OAK",
      "Pittsburgh Pirates" => "PIT",
      "Seattle Mariners" => "SEA",
      "San Diego Padres" => "SD",
      "Tampa Bay Rays" => "TB",
      "San Francisco Giants" => "SF",
      "Texas Rangers" => "TEX",
      "St. Louis Cardinals" => "STL",
      "Toronto Blue Jays" => "TOR",
      "Washington Nationals" => "WAS",
    }

    return teams[team]
  end

  def format_start_time(time)
    return time.to_date.strftime("%-m/%-d/%-y")
  end

  def matchup_label(line)
    return "#{abbrev_team(line.game.away_team_name)} @ #{abbrev_team(line.game.away_team_name)} (#{ format_start_time(line.game.starts_at)})"
  end
end
