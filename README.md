## Blackjack Table (Junior Demo)

This Rails app shows a very small Blackjack table. You can create a game, add players by name, and hand out two random cards to every player. It is intentionally simple—think of it as a to-do list that stores players instead of tasks.

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
   - press **Deal Cards** to randomly give two cards to each player.

Cards come from a single 52-card deck that sits on the dealer. Once the deck is empty, start a new game.

### Tests

```bash
bin/rails test
```

### Possible Next Steps

- Track win/loss logic and scoring.
- Allow multiple rounds without recreating the game.
- Add betting and player balances that change after each round.
