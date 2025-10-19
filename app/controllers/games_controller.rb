class GamesController < ApplicationController
  helper_method :hand_total, :cards_for
  before_action :set_game, only: %i[show add_player place_bet deal hit stand]

  def new
    @game = Game.new
  end

  def create
    @game = Game.create!(status: "waiting")
    build_deck_for(@game)
    redirect_to @game
  end

  def show
    @round = ensure_round
    @dealer = @game.dealer
    @players = @game.players.participants.includes(:cards)
    @deck_count = @game.cards.in_deck.count
    @dealer_cards = cards_for(@dealer).to_a
    @dealer_total = hand_total(@dealer_cards)
    @active_player = active_player
  end

  def add_player
    name = params[:player_name].presence || default_player_name
    @game.players.create!(name: name, is_dealer: false, balance: 500, current_bet: 0, stood: false)
    redirect_to @game
  end

  def place_bet
    if @game.status == "player_turn"
      redirect_to @game, alert: "Can't change bets during an active round."
      return
    end

    attrs = bet_params
    player = @game.players.participants.find_by(id: attrs[:player_id])

    unless player
      redirect_to @game, alert: "Player not found."
      return
    end

    amount = attrs[:amount].to_i

    if amount <= 0
      redirect_to @game, alert: "Bet must be greater than zero."
      return
    end

    if amount > player.balance
      redirect_to @game, alert: "#{player.name} can't bet more than their balance."
      return
    end

    player.update!(current_bet: amount)
    redirect_to @game, notice: "#{player.name}'s bet set to #{helpers.number_to_currency(amount)}."
  end

  def deal
    @round = ensure_round
    if @game.players.participants.none?
      redirect_to @game, alert: "Add at least one player before dealing cards."
      return
    end

    ready, error_message = bets_ready?
    unless ready
      redirect_to @game, alert: error_message
      return
    end

    reset_table_state!
    dealer = @game.dealer

    @game.players.participants.find_each do |player|
      player.reload
      player.update!(balance: player.balance - player.current_bet, stood: false)
      2.times { deal_one_card_to(player) }
    end

    2.times { deal_one_card_to(dealer) } if dealer
    @game.update!(status: "player_turn")

    flash[:notice] = "Cards dealt!"
    finish_round_if_ready

    redirect_to @game
  end

  def hit
    @round = ensure_round
    unless @game.status == "player_turn"
      redirect_to @game, alert: "Deal a round before hitting."
      return
    end

    player = player_from_params || active_player
    if player.nil?
      redirect_to @game, alert: "No player selected."
      return
    end

    if player.stood?
      redirect_to @game, alert: "#{player.name} already stood."
      return
    end

    deal_one_card_to(player)
    player_cards = cards_for(player)
    total = hand_total(player_cards)

    if total > 21
      player.update!(stood: true)
      flash[:alert] = "#{player.name} busts with #{total}."
    elsif total == 21
      player.update!(stood: true)
      flash[:notice] = "#{player.name} hits 21!"
    else
      flash[:notice] = "#{player.name} hits and shows #{total}."
    end

    finish_round_if_ready
    redirect_to @game
  end

  def stand
    @round = ensure_round
    unless @game.status == "player_turn"
      redirect_to @game, alert: "Deal a round before standing."
      return
    end

    player = player_from_params || active_player
    unless player
      redirect_to @game, alert: "No player selected."
      return
    end

    player.update!(stood: true)
    flash[:notice] = "#{player.name} stands with #{hand_total(cards_for(player))}."

    finish_round_if_ready
    redirect_to @game
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def build_deck_for(game)
    dealer = game.players.create!(name: "Dealer", is_dealer: true, balance: 0, current_bet: 0)
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

  def bet_params
    params.require(:bet).permit(:player_id, :amount)
  end

  def bets_ready?
    players = @game.players.participants.to_a

    missing = players.select { |player| player.current_bet.to_i <= 0 }
    if missing.any?
      names = missing.map(&:name).join(", ")
      return [ false, "Set bets for: #{names}." ]
    end

    over = players.select { |player| player.current_bet > player.balance }
    if over.any?
      names = over.map(&:name).join(", ")
      return [ false, "Bet exceeds balance for: #{names}." ]
    end

    [ true, nil ]
  end

  def dealer_cards_for_display
    cards_for(@dealer || @game.dealer)
  end

  def cards_for(player)
    round = ensure_round
    return [] unless player && round

    player.cards.where(round: round, in_deck: false)
  end

  def active_player
    @game.players.participants.order(:created_at).find do |player|
      next if player.stood?

      hand_total(cards_for(player)) < 21
    end
  end

  def player_from_params
    player_id = params[:player_id]
    return nil unless player_id

    @game.players.participants.find_by(id: player_id)
  end

  def hand_total(cards)
    return 0 if cards.blank?

    total = 0
    aces = 0

    cards.each do |card|
      value =
        case card.rank
        when "ace"
          aces += 1
          11
        when "king", "queen", "jack"
          10
        else
          card.rank.to_i
        end
      total += value
    end

    while total > 21 && aces.positive?
      total -= 10
      aces -= 1
    end

    total
  end

  def reset_table_state!
    @round = ensure_round
    dealer = @game.dealer
    return unless dealer

    @game.cards.update_all(in_deck: true, player_id: dealer.id)
    @game.players.participants.update_all(stood: false)
  end

  def finish_round_if_ready
    return if @game.status == "finished"
    return unless all_players_done?

    dealer = @game.dealer
    return unless dealer

    draw_for_dealer!(dealer)
    dealer_total = hand_total(cards_for(dealer))

    messages = @game.players.participants.map do |player|
      settle_player!(player, dealer_total)
    end

    combined = messages.compact.join(" ")
    flash[:notice] = [flash[:notice], combined.presence].compact.join(" ").strip
    @game.update!(status: "finished")
  end

  def all_players_done?
    @game.players.participants.all? { |player| player_done?(player) }
  end

  def player_done?(player)
    return true if player.stood?

    hand_total(cards_for(player)) >= 21
  end

  def draw_for_dealer!(dealer)
    while hand_total(cards_for(dealer)) < 17 && @game.cards.in_deck.exists?
      deal_one_card_to(dealer)
      @game.reload
      dealer.reload
      @round = ensure_round
    end
  end

  def settle_player!(player, dealer_total)
    player.reload
    bet = player.current_bet
    player_total = hand_total(cards_for(player))
    message = nil

    if player_total > 21
      # player already lost their stake when cards were dealt
    elsif dealer_total > 21
      player.record_win!
      player.increment!(:balance, bet * 2)
      message = "#{player.name} wins! Dealer busts at #{dealer_total}."
    elsif player_total > dealer_total
      player.record_win!
      player.increment!(:balance, bet * 2)
      message = "#{player.name} wins with #{player_total}."
    elsif player_total < dealer_total
      message = "#{player.name} loses with #{player_total} (dealer #{dealer_total})."
    else
      player.increment!(:balance, bet)
      message = "#{player.name} pushes with #{player_total}."
    end

    player.update!(current_bet: 0)
    message
  end

  def ensure_round
    @round ||= @game.current_round || @game.rounds.first || @game.rounds.create!
  end
end
