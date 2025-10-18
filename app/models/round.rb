class Round < ApplicationRecord
  belongs_to :game
  has_many :cards, dependent: :destroy
end
