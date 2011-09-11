require 'minitest/autorun'
require 'cosmic_wimpout'

# minitest info: http://bfts.rubyforge.org/minitest/

describe CosmicWimpout::Game do

  before do
    @tortoise = CosmicWimpout::Player.new "Tortoise"
    @achilles = CosmicWimpout::Player.new "Achilles"
    @game = CosmicWimpout::Game.new @tortoise, @achilles
  end

  describe "when played by several people" do
    it "should cycle through the players" do
      fox_the_dice :two, :two, :three, :three, :four

      @game.current_player.name.must_equal "Tortoise"
      2.times do
        @game.take_turn
        @game.current_player.name.must_equal "Achilles"
        @game.take_turn
        @game.current_player.name.must_equal "Tortoise"
      end
    end
  end

  describe "when numbers and symbols are rolled" do
    it "should let the player decide: re-roll the symbol cubes?" do
      fox_the_dice(5, 10, [:two, 5], [:two, 10], [:three, :four, 10])
    end
  end

  describe "when the turn ends" do
    it "should add the turn points to the current player's total" do
      fox_the_dice(5, 5, 5, 10, 10)
      @game.take_turn
      @tortoise.points.must_equal 35
    end
  end

  def fox_the_dice(*vals)
    fixed_cubes = vals.map { |v| FixedCube.new(v) }
    cubes = @game.instance_variable_set :@cubes, fixed_cubes
  end

  class FixedCube < CosmicWimpout::Cube
    def initialize(values)
      values = [values] unless Array === values
      @fixed_rolls = values.cycle
    end
    def toss
      @face_up = @fixed_rolls.next
    end
  end

end
