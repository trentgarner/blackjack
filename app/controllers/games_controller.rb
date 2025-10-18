class GamesController < ApplicationController
  before_action :set_game, only: %i[show add_player deal]

  def new
    @game = Game.new
  end

  def create
    @game = Game.create!(status: "waiting")
    build_deck_for(@game)
    redirect_to @game
  end

  def show
    @round = @game.current_round
    @dealer = @game.dealer
    @players = @game.players.participants.includes(:cards)
    @deck_count = @game.cards.in_deck.count
  end

  def add_player
    name = params[:player_name].presence || default_player_name
    @game.players.create!(name: name, is_dealer: false, balance: 0)
    redirect_to @game
  end

  def deal
    if @game.players.participants.none?
      redirect_to @game, alert: "Add at least one player before dealing cards."
      return
    end

    unless @game.cards.in_deck.exists?
      redirect_to @game, alert: "Deck is empty. Start a new game."
      return
    end

    @game.players.participants.find_each do |player|
      2.times { deal_one_card_to(player) }
    end

    redirect_to @game, notice: "Cards dealt!"
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def build_deck_for(game)
    dealer = game.players.create!(name: "Dealer", is_dealer: true, balance: 0)
    round = game.rounds.create!

    position = 0
    Card::SUITS.each do |suit|
      Card::RANKS.each do |rank|
        round.cards.create!(
          rank: rank,
          suit: suit,
          position: position,
          in_deck: true,
          player: dealer
        )
        position += 1
      end
    end
  end

  def deal_one_card_to(player)
    card = @game.cards.in_deck.order("RANDOM()").first
    return unless card

    card.update!(player: player, in_deck: false)
  end

  def default_player_name
    next_index = @game.players.participants.count + 1
    "Player #{next_index}"
  end
end
