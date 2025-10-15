class CreateGames < ActiveRecord::Migration[7.2]
  def change
    create_table :games do |t|
      t.text :deck_state
      t.text :player_cards_state
      t.text :dealer_cards_state
      t.string :status
      t.string :outcome_message

      t.timestamps
    end
  end
end
