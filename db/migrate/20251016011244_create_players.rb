class CreatePlayers < ActiveRecord::Migration[7.2]
  def change
    create_table :players do |t|
      t.string :name
      t.decimal :balance
      t.boolean :is_dealer
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
