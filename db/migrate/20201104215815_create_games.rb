class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.string :away_team_name
      t.string :home_team_name
      t.jsonb :details, default: {}
      t.jsonb :boxscore, default: {}
      t.string :starts_at
      t.string :schedule_date
      t.timestamps
    end
  end
end
