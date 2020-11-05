class Game < ApplicationRecord
  has_many :stat_lines, dependent: :destroy
  has_many :players, through: :stat_lines
end
