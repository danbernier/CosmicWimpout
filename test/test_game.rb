require 'minitest/autorun'
require 'cosmic_wimpout'

# minitest info: http://bfts.rubyforge.org/minitest/

describe CosmicWimpout::Game do

  before do
    @game = CosmicWimpout::Game.new "Right", "Said", "Fred"
  end

  describe "when played by several people" do
    it "should cycle through the players" do
      @game.current_player.name.must_equal "Right"
      @game.toss_cubes
      @game.current_player.name.must_equal "Said"
      @game.toss_cubes
      @game.current_player.name.must_equal "Fred"
      @game.toss_cubes
      @game.current_player.name.must_equal "Right"
      @game.toss_cubes
      @game.current_player.name.must_equal "Said"
    end
  end

  describe "when the turn ends" do
    it "should add the turn points to the current player's total" do
      fox_the_dice(5, 10, :two, :two, :three)
      @game.toss_cubes

      # Cycle through the other players (sheesh)
      fox_the_dice(0, 0, 0, 0, 0)
      @game.toss_cubes; @game.toss_cubes

      @game.current_player.points.must_equal 15
    end
  end

  def fox_the_dice(*vals)
    fixed_cubes = vals.map { |v| FixedCube.new(v) }
    cubes = @game.instance_variable_set :@cubes, fixed_cubes
  end

end

class FixedCube
  attr_reader :face_up
  def initialize(value)
    @face_up = value
  end
  def toss
  end
end
