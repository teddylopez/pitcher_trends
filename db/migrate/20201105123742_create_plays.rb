class CreatePlays < ActiveRecord::Migration[5.2]
  def change
    create_table :plays do |t|
      t.references :game, index: true
      t.integer :batter_id, index: true
      t.integer :pitcher_id, index: true
      t.jsonb :pitch, default: {}
      t.string :pitch_type
      t.string :event_type

      t.timestamps
    end

    add_foreign_key :plays, :players, column: :pitcher_id

  end
end
