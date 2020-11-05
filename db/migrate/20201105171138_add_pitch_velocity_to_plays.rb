class AddPitchVelocityToPlays < ActiveRecord::Migration[5.2]
  def change
    add_column :plays, :pitch_velocity, :float
  end
end
