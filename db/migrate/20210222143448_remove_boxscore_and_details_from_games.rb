class RemoveBoxscoreAndDetailsFromGames < ActiveRecord::Migration[5.2]
  def change
    remove_column :games, :boxscore
    remove_column :games, :details
  end
end
