class CreateCards < ActiveRecord::Migration[7.2]
  def change
    create_table :cards do |t|
      t.string :rank
      t.string :suit
      t.references :round, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.integer :position
      t.boolean :in_deck

      t.timestamps
    end
  end
end
