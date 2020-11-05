class PlayersController < ApplicationController
  include PlayersHelper
  before_action :set_player, only: [:trends, :build_charts]

  def trends
    @last_five_lines = StatLine.includes(:game)
                               .where(player_id: @player.id)
                               .references(:game)
                               .order('starts_at')
                               .last(5)

    last_five_pitch_count = @last_five_lines.map{|start| start['stats']['number_of_pitches']}
    @number_of_pitches = last_five_pitch_count.reject{|x| x == nil}.inject{|sum, el| sum + el}
    @avg_pitch_count = (@number_of_pitches / last_five_pitch_count.length)
  end

  def build_charts
    total_plays = Play.includes(:game).where("pitcher_id = #{@player.id}").order("Games.starts_at ASC").select(:pitch)

    years = total_plays.pluck(:starts_at).uniq
    season_plays = total_plays.where("Games.starts_at > '#{years.min.to_i}-01-01 00:00:00' AND Games.starts_at < '#{years.max.to_i + 1}-01-01 00:00:00'")

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
      date = play.game.starts_at.to_s.to_date
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
          if pitch_hash[pitch][:date][date].present?
            chart_key.each_with_index do |attr, i|
              pitch_hash[pitch][:date][date][chart_key.keys[i]].push(chart_key.values[i]).reject! {|x| x == 0.0 || x == nil}
            end

          # If pitch[date] doesn't exist yet, create new date key with info arrays
          else
            pitch_hash[pitch][:date][date] = {velo:[], height:[], extension:[], spin:[], hbreak:[], vbreak:[], axis:[]}

            chart_key.each_with_index do |attr, i|
              pitch_hash[pitch][:date][date][chart_key.keys[i]].push(chart_key.values[i]).reject! {|x| x == 0.0 || x == nil}
            end
          end

        # If pitch doesn't exist in hash, create it
        else
          pitch_hash[pitch][:date] = Hash.new { |hash, key| hash[key] = {} }
          pitch_hash[pitch][:date][date] = {velo:[], height:[], extension:[], spin:[], hbreak:[], vbreak:[], axis:[]}

          chart_key.each_with_index do |attr, i|
            pitch_hash[pitch][:date][date][chart_key.keys[i]].push(chart_key.values[i]).reject! {|x| x == 0.0 || x == nil}
          end
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
        years.push(date.strftime("%Y")) unless years.include?(date.strftime("%Y"))
        date_labels[date.strftime("%Y")].present? ? date_labels[date.strftime("%Y")].push(d[0]) : date_labels[date.strftime("%Y")] = [d[0]]

        # Average arrays and round to two decimals:
        d[1][:velo].present? ? velo = (d[1][:velo].inject { |sum, el| sum + el } / d[1][:velo].size).round(2) : velo = nil
        d[1][:height].present? ? height = (d[1][:height].inject { |sum, el| sum + el } / d[1][:height].size).round(2) : height = nil
        d[1][:extension].present? ? extension = (d[1][:extension].inject { |sum, el| sum + el } / d[1][:extension].size).round(2) : extension = nil
        d[1][:spin].present? ? spin = (d[1][:spin].inject { |sum, el| sum + el } / d[1][:spin].size).round(2) : spin = nil
        d[1][:hbreak].present? ? hbreak = (d[1][:hbreak].inject { |sum, el| sum + el } / d[1][:vbreak].size).round(2) : hbreak = nil
        d[1][:vbreak].present? ? vbreak = (d[1][:vbreak].inject { |sum, el| sum + el } / d[1][:hbreak].size).round(2) : vbreak = nil
        d[1][:axis].present? ? axis = (d[1][:axis].inject { |sum, el| sum + el } / d[1][:axis].size).round(2) : axis = nil

        attr_key = {
          velo: velo,
          height: height,
          extension: extension,
          spin: spin,
          hbreak: hbreak,
          vbreak: vbreak,
          axis: axis
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
      seasons: years.reverse,
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
    pitch_type_hash = Hash["CU" => "Curveball", "FF" => "Fourseam", "CH" => "Changeup", "FT" => "Twoseam", "nil" => ""]
    return pitch_type_hash["#{pitch}"]
  end
end
