class Game < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :rounds, dependent: :destroy
  has_many :cards, through: :rounds

  def dealer
    players.find_by(is_dealer: true)
  end

  def current_round
    rounds.order(created_at: :desc).first
  end
end
