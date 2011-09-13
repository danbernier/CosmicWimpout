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

  describe "when numbers and symbols are tossed" do
    it "should let the player decide: re-toss the symbol cubes?" do
      fox_the_dice(5, 10, [:two, 10], [:two, 10], [:three, :four])

      @tortoise.points = 100
      @achilles.points = 100

      # Tortoise will get 15 pts first toss, and re-toss.
      # He'll get 20 more second toss, and stop.
      @tortoise.tosses_if do |cubes, turn_points|
        cubes.size > 1
      end

      @game.take_turn

      @tortoise.points.must_equal 135
      @tortoise.toss_decisions[0].must_equal [[:two, :two, :three], 15]
      @tortoise.toss_decisions[1].must_equal [[:four], 35]

      # Achilles ALWAYS tosses. Eventually, he'll lose his points.
      @achilles.tosses_if do |cubes, turn_points|
        true  # Too eager!
      end

      @game.take_turn

      @achilles.points.must_equal 100
      @achilles.toss_decisions[0].must_equal [[:two, :two, :three], 15]
      @achilles.toss_decisions[1].must_equal [[:four], 35]
    end
  end

  describe "when players have no points banked" do
    it "won't let them stop until they have 35 points" do
      fox_the_dice(5, :two, :four, :four, :six)

      @game.take_turn

      # Tortoise has no points banked, so he never has a chance to quit
      # after tossing the first 5 cubes.
      @tortoise.toss_decisions.size.must_equal 0

      # And his turn ended, so he still has no points.
      @tortoise.points.must_equal 0
    end
  end

  describe "when only symbols are tossed" do
    it "should end the turn immediately, with 0 points" do
      fox_the_dice :two, :three, :six, :two, :four

      @game.take_turn

      @tortoise.points.must_equal 0
      @tortoise.toss_decisions.size.must_equal 0
    end
  end

  describe "when the player scores on all 5 cubes" do
    it "must make them re-toss all 5 cubes" do
      fox_the_dice 5, 5, 10, 10, [:two, 10]

      @tortoise.points = 100
      @tortoise.tosses_if do |cubes, turn_points|
        turn_points <= 30 # Just make him say 'yes', the first time.
      end

      @game.take_turn

      # He started with 100, he got 40 from first round, & 30 from second.
      @tortoise.points.must_equal 170
    end
  end

  describe "when the turn ends" do
    it "should add the turn points to the current player's total" do
      # TODO This will break when we introduce the flash rule.
      fox_the_dice(5, 5, 5, 10, :two)
      @tortoise.points = 100
      @tortoise.tosses_if { false }

      @game.take_turn

      @tortoise.points.must_equal 125
    end
  end

  def fox_the_dice(*vals)
    fixed_cubes = vals.map { |v| FixedCube.new(v) }
    cubes = @game.instance_variable_set(:@cubes, fixed_cubes)
  end

  class FixedCube < CosmicWimpout::Cube

    def initialize(values)
      values = [values] unless Array === values
      @fixed_toss_values = values.cycle
    end

    def toss
      @face_up = @fixed_toss_values.next
    end

  end

  class MockPlayer < CosmicWimpout::Player

    attr_accessor :toss_decisions, :points

    def initialize(name)
      super(name)
      @toss_decisions = []
    end

    def tosses_if(&block)
      @toss_when = block
    end

    def toss_again?(cubes, turn_points)
      @toss_decisions.push [cubes.map(&:face_up), turn_points]
      @toss_when.call(cubes, turn_points)
    end

  end
end
