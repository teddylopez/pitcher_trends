class PlayersController < ApplicationController
  before_action :set_player, only: [:trends, :build_charts]

  def trends
    @last_five_lines = StatLine.includes(:game)
                               .where(player_id: @player.id)
                               .references(:game)
                               .order('starts_at')
                               .last(5)

    last_five_pitch_count = @last_five_lines.map{|start| start['stats']['number_of_pitches']}
    @number_of_pitches = last_five_pitch_count.inject{|sum, el| sum + el}
    @avg_pitch_count = (@number_of_pitches / last_five_pitch_count.length)
  end

  def build_charts
    total_plays = Play.includes(:game).where("pitcher_id = #{@player.id}").order("Games.starts_at ASC")
    appearances = total_plays.pluck(:starts_at).uniq.sort
    season_plays = total_plays.where("Games.starts_at > '#{appearances.first.to_i}' AND Games.starts_at < '#{appearances.first.to_i + 1}'")

    pitch_hash = Hash.new { |hash, key| hash[key] = {} }
    years = []
    date_labels = {}
    velo_data = []
    height_data = []
    extension_data = []
    spin_data = []
    hbreak_data = []
    vbreak_data = []
    axis_data = []
    data_groups = [velo_data, height_data, extension_data, spin_data, hbreak_data, vbreak_data, axis_data]

    season_plays.each do |play|
      date = play.game.starts_at.to_date
      pitch = translate_pitch_type(play.pitch_type)
      velo = play.pitch_velocity.to_f
      height = play.pitch['releaseData']['releasePosition']['z'].to_f if play.pitch['releaseData']
      extension = play.pitch['releaseData']['extension'].to_f if play.pitch['releaseData']
      spin = play.pitch['releaseData']['spinRate'].to_f if play.pitch['releaseData']
      hbreak = play.pitch['trajectoryData']['horizontalBreak'].to_f if play.pitch['trajectoryData']
      vbreak = play.pitch['trajectoryData']['verticalBreak'].to_f if play.pitch['trajectoryData']
      axis = play.pitch['releaseData']['spinAxis'].to_f if play.pitch['releaseData']
      chart_key = {velo: velo, height: height, extension: extension, spin: spin, hbreak: hbreak, vbreak: vbreak, axis: axis}

      # Build hash of organized pitch data:
      unless pitch == nil
        if pitch_hash[pitch].present?
          if !pitch_hash[pitch][:date][date].present?
            pitch_hash[pitch][:date][date] = {velo:[], height:[], extension:[], spin:[], hbreak:[], vbreak:[], axis:[]}
          end

        else
          pitch_hash[pitch][:date] = Hash.new { |hash, key| hash[key] = {} }
          pitch_hash[pitch][:date][date] = {velo:[], height:[], extension:[], spin:[], hbreak:[], vbreak:[], axis:[]}
        end

        chart_key.each_with_index do |attr, i|
          pitch_hash[pitch][:date][date][chart_key.keys[i]].push(chart_key.values[i])
        end
      end
    end

    pitch_hash.each do |p|

      datasets = {
        velo_data: { label: [], season: {} },
        height_data: { label: [], season: {} },
        extension_data: { label: [], season: {} },
        spin_data: { label: [], season: {} },
        hbreak_data: { label: [], season: {} },
        vbreak_data: { label: [], season: {} },
        axis_data: { label: [], season: {} }
      }

      # Set labels to pitch-type:
      datasets.each { |d| d[1][:label] = p[0] }

      # Set pitch attribute data:
      p[1][:date].each do |d|
        date = d[0]
        years.push(date.strftime("%Y"))
        date_labels[date.strftime("%Y")].present? ? date_labels[date.strftime("%Y")].push(d[0]) : date_labels[date.strftime("%Y")] = [d[0]]

        attr_key = {
          velo: avg_and_round(d[1][:velo]),
          height: avg_and_round(d[1][:height]),
          extension: avg_and_round(d[1][:extension]),
          spin: avg_and_round(d[1][:spin]),
          hbreak: avg_and_round(d[1][:hbreak]),
          vbreak: avg_and_round(d[1][:vbreak]),
          axis: avg_and_round(d[1][:axis])
        }

        datasets.each_with_index do |set, i|
          datapoint = { x: date.strftime("%B %d, %Y"), y: attr_key.values[i] }

          if set[1][:season][date.strftime("%Y")].present?
            set[1][:season][date.strftime("%Y")][:data].push(datapoint)
          else
            set[1][:season][date.strftime("%Y")] = { data: [datapoint] }
          end
        end
      end

      set_key = [
        datasets[:velo_data],
        datasets[:height_data],
        datasets[:extension_data],
        datasets[:spin_data],
        datasets[:hbreak_data],
        datasets[:vbreak_data],
        datasets[:axis_data]
      ]

      # Push data to output arrays for charts:
      data_groups.each_with_index do |group, i|
        group.push(set_key[i])
      end
    end

    output = {
      seasons: years.reverse.uniq,
      labels: date_labels,
      datasets: {
        velo_data: data_groups[0],
        height_data: data_groups[1],
        extension_data: data_groups[2],
        spin_data: data_groups[3],
        hbreak_data: data_groups[4],
        vbreak_data: data_groups[5],
        axis_data: data_groups[6]
      }
    }

    render json: {data: output}

  end

  private

  def set_player
    @player = Player.first
  end

  def translate_pitch_type(pitch)
    pitch_type_hash = Hash["CU" => "Curveball", "FF" => "Fourseam", "CH" => "Changeup", "FT" => "Twoseam"]
    return pitch_type_hash["#{pitch}"]
  end

  def avg_and_round(attr)
    return (attr.inject { |sum, el| sum + el } / attr.size).round(2)
  end
end
