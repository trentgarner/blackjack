class AddStoodToPlayers < ActiveRecord::Migration[7.1]
  def change
    add_column :players, :stood, :boolean, default: false, null: false unless column_exists?(:players, :stood)
  end
end
