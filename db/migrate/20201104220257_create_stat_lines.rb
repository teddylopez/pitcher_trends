class CreateStatLines < ActiveRecord::Migration[5.2]
  def change
    create_table :stat_lines do |t|
      t.jsonb :stats, default: {}
      t.references :game, index: true, foreign_key: true
      t.references :player, index: true, foreign_key: true
      t.timestamps
    end
  end
end
