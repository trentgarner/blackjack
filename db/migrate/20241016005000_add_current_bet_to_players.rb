class AddCurrentBetToPlayers < ActiveRecord::Migration[7.1]
  def change
    add_column :players, :current_bet, :integer, default: 0, null: false unless column_exists?(:players, :current_bet)
  end
end
