module PlayersHelper
  def shorten_team_name(team)
    return team.split.last
  end

  def format_start_time(time)
    return time.to_date.strftime("%-m/%-d/%-y")
  end

  def style_pitch_count_warning(pitch_count)
    if pitch_count.to_i < 95
      return "low-risk"
    elsif pitch_count.to_i > 90 && pitch_count.to_i < 109
      return "medium-risk"
    else
      return "high-risk"
    end
  end
end
