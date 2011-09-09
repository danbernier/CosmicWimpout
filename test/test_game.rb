require 'minitest/autorun'
require 'cosmic_wimpout'

describe CosmicWimpout::Game do

  before do
    @game = CosmicWimpout::Game.new "Right", "Said", "Fred"
  end

  describe "when played by several people" do
    it "should cycle through the players" do
      @game.current_player.name.must_equal "Right"
      @game.end_turn
      @game.current_player.name.must_equal "Said"
      @game.end_turn
      @game.current_player.name.must_equal "Fred"
      @game.end_turn
      @game.current_player.name.must_equal "Right"
      @game.end_turn
      @game.current_player.name.must_equal "Said"
    end
  end

end
