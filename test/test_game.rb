require 'minitest/autorun'
require 'cosmic_wimpout'

# minitest info: http://bfts.rubyforge.org/minitest/

describe CosmicWimpout::Game do

  before do
    @tortoise = MockPlayer.new "Tortoise"
    @achilles = MockPlayer.new "Achilles"
    @game = CosmicWimpout::Game.new(500, @tortoise, @achilles)

    # TODO make the Tortoise never re-roll, and Achilles always re-roll
    # (That's what your tests are doing, anyway.)
  end

  describe "when played by several people" do
    it "should cycle through the players" do
      fox_the_cubes :two, :two, :three, :three, :four

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
      fox_the_cubes(5, 10, [:two, 10], [:two, 10], [:three, :four])

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
      fox_the_cubes(5, :two, :four, :four, :six)

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
      fox_the_cubes :two, :three, :six, :two, :four

      @game.take_turn

      @tortoise.points.must_equal 0
      @tortoise.toss_decisions.size.must_equal 0
    end
  end

  describe "when the player scores on all 5 cubes" do
    it "must make them re-toss all 5 cubes" do
      fox_the_cubes 5, 5, 10, 10, [:two, 10]

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
      fox_the_cubes(5, 5, 5, 10, :two)
      @tortoise.points = 100
      @tortoise.tosses_if { false }

      @game.take_turn

      @tortoise.points.must_equal 125
    end
  end

  describe "when one player gets more than the max number of points" do
    it "should enter last-licks" do
      @tortoise.points = 470
      @achilles.points = 0
      fox_the_cubes(10, 10, 5, 5, :two)
      @tortoise.tosses_if { false }
      @achilles.tosses_if { true }

      @game.take_turn  # Tortoise earns 30 points: start last licks.
      @game.in_last_licks?.must_equal true
      @game.over?.must_equal false
      @game.take_turn  # Achilles' turn: he earns 0 points.

      # With no other players, and Achilles' turn over, the game is over.
      @game.over?.must_equal true
      @game.in_last_licks?.must_equal false
      @game.winning_player.must_equal @tortoise
    end
  end

  describe "when the game is over" do
    it "should not let anyone take a turn" do
      @tortoise.points = 470
      @achilles.points = 0
      fox_the_cubes(10, 10, 5, 5, :two)
      @tortoise.tosses_if { false }
      @achilles.tosses_if { true } # Too eager: he'll wimpout on the two.

      @game.over?.must_equal false
      @game.take_turn  # Tortoise earns 30 points: enter last licks
      @game.take_turn  # Achilles wimps out, ending the game.
      @game.over?.must_equal true
      proc { @game.take_turn }.must_raise CosmicWimpout::GameOverException
    end

    it "should announce the correct winner" do
      @tortoise.points = 470
      @achilles.points = 0
      fox_the_cubes(10, 10, 5, 5, :two)
      @tortoise.tosses_if { false }
      @achilles.tosses_if { true }

      def @game.announce_winner
        @winner_was_announced = true
      end

      @game.winning_player.must_be_nil
      @game.take_turn  # Tortoise starts last licks
      @game.take_turn  # Achilles wimps out
      @game.winning_player.must_equal @tortoise
      @game.instance_variable_get(:@winner_was_announced).must_equal true
    end
  end

  # TODO when you get to last licks, make sure you test for a tie game.
  # (Actually, the game is unclear about how to handle a tie. I guess most
  #  players just keep going.)

  def fox_the_cubes(*vals)
    foxed_cubes = vals.map { |v| FoxedCube.new(v) }
    cubes = @game.instance_variable_set(:@cubes, foxed_cubes)
  end

  class FoxedCube
    include CosmicWimpout::Cube

    def initialize(values)
      values = [values] unless Array === values
      @fixed_toss_values = values.cycle
    end

    def toss!
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
