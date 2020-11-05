require "csv"

namespace :build do
  desc "Build out basic table structures"
  
  task :tables => :environment do |t, args|
    ["players", "games", "stat_lines", "plays"].each_with_index do |csv_file, i|
      models = [Player, Game, StatLine, Play]
      path = Rails.root.join('lib', "#{csv_file}.csv")

      CSV.foreach(path, :headers => true, encoding: "UTF-8") do |row|
         models[i].create(row.to_hash)
      end

      puts "#{csv_file} table created!"
    end
  end

end
