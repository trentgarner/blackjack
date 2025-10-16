class CreateRounds < ActiveRecord::Migration[7.2]
  def change
    create_table :rounds do |t|
      t.references :game, null: false, foreign_key: true
      t.integer :status
      t.decimal :bet
      t.string :outcome_message

      t.timestamps
    end
  end
end
