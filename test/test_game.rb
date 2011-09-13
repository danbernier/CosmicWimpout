require 'minitest/autorun'
require 'cosmic_wimpout'

# minitest info: http://bfts.rubyforge.org/minitest/

describe CosmicWimpout::Game do

  before do
    @tortoise = MockPlayer.new "Tortoise"
    @achilles = MockPlayer.new "Achilles"
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
      fox_the_dice(5, 10, [:two, 10], [:two, 10], [:three, :four])

      @tortoise.points = 100
      @achilles.points = 100

      # Tortoise will get 15 pts first toss, and re-roll.
      # He'll get 20 more second toss, and stop.
      @tortoise.rerolls_if do |cubes, turn_points|
        cubes.size > 1
      end

      @game.take_turn

      @tortoise.points.must_equal 135
      @tortoise.roll_decisions[0].must_equal [[:two, :two, :three], 15]
      @tortoise.roll_decisions[1].must_equal [[:four], 35]

      # Achilles ALWAYS re-rolls. Eventually, he'll lose his points.
      @achilles.rerolls_if do |cubes, turn_points|
        true  # Too eager!
      end

      @game.take_turn

      @achilles.points.must_equal 100
      @achilles.roll_decisions[0].must_equal [[:two, :two, :three], 15]
      @achilles.roll_decisions[1].must_equal [[:four], 35]
    end
  end

  describe "when players have no points banked" do
    it "won't let them stop until they have 35 points" do
      fox_the_dice(5, :two, :four, :four, :six)

      @game.take_turn

      # Tortoise has no points banked, so he never has a chance to quit
      # after rolling the first 5.
      @tortoise.roll_decisions.size.must_equal 0

      # And his turn ended, so he still has no points.
      @tortoise.points.must_equal 0
    end
  end

  describe "when only symbols are rolled" do
    it "should end the turn immediately, with 0 points" do
      fox_the_dice :two, :three, :six, :two, :four

      @game.take_turn

      @tortoise.points.must_equal 0
      @tortoise.roll_decisions.size.must_equal 0
    end
  end

  describe "when only numbers are rolled" do
    it "should end the turn immediately, with all the points" do
      fox_the_dice 5, 5, 10, 10, 10

      @game.take_turn

      @tortoise.points.must_equal 40
      @tortoise.roll_decisions.size.must_equal 0
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
    cubes = @game.instance_variable_set(:@cubes, fixed_cubes)
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

  class MockPlayer < CosmicWimpout::Player

    attr_accessor :roll_decisions, :points

    def initialize(name)
      super(name)
      @roll_decisions = []
    end

    def rerolls_if(&block)
      @reroll_when = block
    end

    def roll_again?(cubes, turn_points)
      @roll_decisions.push [cubes.map(&:face_up), turn_points]
      @reroll_when.call(cubes, turn_points)
    end

  end
end
