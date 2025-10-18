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

    game.players.participants.each do |player|
      assert_equal 2, player.cards.where(in_deck: false).count
    end
  end
end
