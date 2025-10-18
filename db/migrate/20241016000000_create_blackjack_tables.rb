class CreateBlackjackTables < ActiveRecord::Migration[7.1]
  def change
    create_table :games, if_not_exists: true do |t|
      t.string :status, default: "waiting", null: false
      t.timestamps
    end

    create_players_table
    create_rounds_table
    create_cards_table
  end

  private

  def create_players_table
    create_table :players, if_not_exists: true do |t|
      t.string :name, null: false
      t.boolean :is_dealer, default: false, null: false
      t.references :game, null: false, foreign_key: true
      t.integer :balance, default: 0, null: false
      t.timestamps
    end
  end

  def create_rounds_table
    create_table :rounds, if_not_exists: true do |t|
      t.references :game, null: false, foreign_key: true
      t.timestamps
    end
  end

  def create_cards_table
    create_table :cards, if_not_exists: true do |t|
      t.string :rank, null: false
      t.string :suit, null: false
      t.boolean :in_deck, default: true, null: false
      t.integer :position
      t.references :round, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.timestamps
    end
  end
end
