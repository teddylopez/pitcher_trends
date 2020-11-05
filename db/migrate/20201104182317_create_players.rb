class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :players do |t|
      t.string :last_name
      t.string :first_name
      t.string :date_of_birth
      t.integer :position
      t.integer :bats
      t.integer :throws

      t.timestamps
    end
  end
end
