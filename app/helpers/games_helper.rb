module GamesHelper
  SUIT_SYMBOLS = {
    "hearts" => "♥",
    "diamonds" => "♦",
    "clubs" => "♣",
    "spades" => "♠"
  }.freeze

  FACE_LABELS = {
    "jack" => "J",
    "queen" => "Q",
    "king" => "K",
    "ace" => "A"
  }.freeze

  def card_suit_symbol(card)
    SUIT_SYMBOLS.fetch(card.suit, "?")
  end

  def card_rank_label(card)
    FACE_LABELS.fetch(card.rank, card.rank).upcase
  end

  def card_css_class(card)
    "suit-#{card.suit}"
  end
end
