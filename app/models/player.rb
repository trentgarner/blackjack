class Player < ApplicationRecord
  belongs_to :game
  has_many :cards, dependent: :destroy

  scope :participants, -> { where(is_dealer: false) }
  scope :dealers, -> { where(is_dealer: true) }

  def stood?
    stood
  end

  def record_win!
    increment!(:wins)
  end
end
