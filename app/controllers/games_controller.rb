class GamesController < ApplicationController
  def new
  end

  def show
  end

  def create
    game = Game.create!
  end
end
