class CreateGames < ActiveRecord::Migration[7.2]
  def change
    create_table :games do |t|
      t.json :state
      t.string :status
      t.string :outcome_message

      t.timestamps
    end
  end
end
