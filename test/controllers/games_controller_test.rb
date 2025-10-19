require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  test "create builds a game with deck" do
    assert_difference -> { Game.count }, +1 do
      post games_path
    end

    game = Game.last
    assert_redirected_to game_path(game)
    assert_not_nil game.dealer
    assert_equal 52, game.cards.count
    assert_equal 52, game.cards.in_deck.count
  end

  test "add player appends participant" do
    post games_path
    game = Game.last

    assert_difference -> { game.players.participants.count }, +1 do
      post add_player_game_path(game), params: { player_name: "Alice" }
    end

    game.reload
    assert_equal ["Alice"], game.players.participants.pluck(:name)
  end

  test "deal hands two cards to each player" do
    post games_path
    game = Game.last

    post add_player_game_path(game), params: { player_name: "Alice" }
    post add_player_game_path(game), params: { player_name: "Bob" }
    game.reload

    post deal_game_path(game)
    game.reload

    game.players.participants.each do |player|
      assert_equal 2, player.cards.where(in_deck: false).count
    end

    dealer = game.dealer
    assert_equal 2, dealer.cards.where(in_deck: false).count
    assert_equal "player_turn", game.reload.status
  end

  test "hit draws card and can bust player" do
    post games_path
    game = Game.last
    post add_player_game_path(game), params: { player_name: "Alice" }
    game.reload
    post deal_game_path(game)
    game.reload

    player = game.players.participants.first
    post hit_game_path(game), params: { player_id: player.id }
    game.reload
    player.reload
    assert_operator player.cards.where(in_deck: false).count, :>=, 3

    post hit_game_path(game), params: { player_id: player.id }
    assert_includes %w[player_turn finished], game.reload.status
  end

  test "stand finishes the round" do
    post games_path
    game = Game.last
    post add_player_game_path(game), params: { player_name: "Alice" }
    post deal_game_path(game)

    player = game.players.participants.first
    post stand_game_path(game), params: { player_id: player.id }

    assert_equal "finished", game.reload.status
  end
end
