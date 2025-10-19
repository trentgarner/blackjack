class AddWinsToPlayers < ActiveRecord::Migration[7.1]
  def change
    add_column :players, :wins, :integer, default: 0, null: false unless column_exists?(:players, :wins)
  end
end
