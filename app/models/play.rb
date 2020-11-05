class Play < ApplicationRecord
  belongs_to :game
  belongs_to :pitcher, foreign_key: :pitcher_id, primary_key: :id, class_name: 'Player'
end
