class Card < ApplicationRecord
  SUITS = %w[hearts diamonds clubs spades].freeze
  RANKS = %w[2 3 4 5 6 7 8 9 10 jack queen king ace].freeze

  belongs_to :round
  belongs_to :player

  scope :in_deck, -> { where(in_deck: true) }
end
