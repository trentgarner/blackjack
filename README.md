## Blackjack Table

This Rails app shows a very small Blackjack table. You can create a game, add players by name, and hand out two random cards to every player.

### Requirements

- Ruby 3.2+
- Bundler
- SQLite (default Rails dev database)

### Setup

```bash
bundle install
bin/rails db:setup
bin/rails server
```

Open http://localhost:3000 and click **Create Game**.

### How It Works

1. Create a game from the landing page.
2. On the game view:
   - add players with the form,
   - set a wager for each player (balances start at $500 and adjust after each round),
   - press **Deal Cards** to randomly give two cards to each player and the dealer,
   - use **Hit** and **Stand** buttons under each player to play out the round.

Wins are tracked per player for the current game; starting a brand-new game creates a fresh table with everyone back at zero wins.

Cards come from a single 52-card deck that sits on the dealer. Once the deck is empty, start a new game.

### Tests

```bash
bin/rails test
```
