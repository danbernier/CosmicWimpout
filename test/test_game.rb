require 'test_helper'

# minitest info: http://bfts.rubyforge.org/minitest/

describe CosmicWimpout::Game do

  before do
    @tortoise = MockPlayer.new "Tortoise"
    @achilles = MockPlayer.new "Achilles"
    @scorer = 
    @game = CosmicWimpout::Game.new(500, [@tortoise, @achilles], SilentTurnView.new)

    # Tortoise never tosses - he'll slowly bank lots of points.
    # Achilles ALWAYS tosses. Eventually, he'll lose his points each turn.
    @tortoise.tosses_if { false }
    @achilles.tosses_if { true }
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

  describe "when player wimps out" do
    it "should end the turn immediately, with 0 points" do
      
      @game.take_turn(scorer: FixedScorer.new(:wimpout))

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
      fox_the_cubes(5, 5, 10, 10, :two)
      @tortoise.points = 100

      @game.take_turn

      @tortoise.points.must_equal 130
    end
  end

  describe "when one player gets more than the max number of points" do
    it "should enter last-licks" do
      @tortoise.points = 470
      @achilles.points = 0

      @game.end_turn(and_bank: 30)  # Tortoise earns 30 points: enter last licks
      @game.in_last_licks?.must_equal true
      @game.over?.must_equal false
      
      @game.end_turn  # Achilles' turn: he earns 0 points.

      # With no other players, and Achilles' turn over, the game is over.
      @game.over?.must_equal true
      @game.in_last_licks?.must_equal false
    end
  end

  describe "when the game is over" do
    it "should not let anyone take a turn" do
      @tortoise.points = 470
      @achilles.points = 0

      @game.end_turn(and_bank: 30)  # Tortoise earns 30 points: enter last licks
      @game.end_turn  # Achilles wimps out, ending the game.
      proc { @game.take_turn }.must_raise RuntimeError
    end

    it "should know the correct winner" do
      @tortoise.points = 470
      @achilles.points = 0

      @game.winning_player.must_be_nil
      @game.end_turn(and_bank: 30)  # Tortoise starts last licks
      @game.end_turn  # Achilles wimps out
      @game.winning_player.must_equal @tortoise
    end
  end
  
  describe 'when a player has 0 banked points' do
    it "should let a player with 35 turn points quit" do
      @tortoise.points = 0
      was_asked = false
      @tortoise.tosses_if { was_asked = true; return true }
      @game.player_quits(@tortoise, [FoxedCube.new(:two)], 35).must_equal true
      was_asked.must_equal true
    end
    
    it "should not let a player with under 35 turn points quit" do
      @tortoise.points = 0
      was_asked = false
      @tortoise.tosses_if { was_asked = true; return true }
      @game.player_quits(@tortoise, [FoxedCube.new(:two)], 30).must_equal false
      was_asked.must_equal false
    end
  end
  
  describe 'when a player has banked points' do
    it "should let a player with 35 turn points quit" do
      @tortoise.points = 35
      was_asked = false
      @tortoise.tosses_if { was_asked = true; return true }
      @game.player_quits(@tortoise, [FoxedCube.new(:two)], 30).must_equal true
      was_asked.must_equal true
    end
    
    it "should not let a player with under 35 turn points quit" do
      @tortoise.points = 35
      was_asked = false
      @tortoise.tosses_if { was_asked = true; return true }
      @game.player_quits(@tortoise, [FoxedCube.new(:two)], 30).must_equal true
      was_asked.must_equal true
    end
  end
  
  describe "when a player rolls Too Many Points" do
    it "kicks them out of the game" do
      players = %w[Tortoise Achilles Douglas].map { |n| MockPlayer.new(n) }
      
      game = CosmicWimpout::Game.new(500, players, SilentTurnView.new)
      
      game.take_turn(scorer: FixedScorer.new(:too_many_points))
      
      game.players.map(&:name).must_equal %w[Achilles Douglas]
    end
    
    it "ends if there's only one player left" do
      players = %w[Tortoise Achilles].map { |n| MockPlayer.new(n) }
      
      game = CosmicWimpout::Game.new(500, players, SilentTurnView.new)
      
      game.take_turn(scorer: FixedScorer.new(:too_many_points))
      
      game.players.map(&:name).must_equal %w[Achilles]
      
      game.over?.must_equal true
    end
  end
  

  # TODO when you get to last licks, make sure you test for a tie game.
  # (Actually, the game is unclear about how to handle a tie. I guess most
  #  players just keep going.)

  # fox_the_cubes(5, 5, 10, 10, :two)
  # fox_the_cubes(5, 5, 10, [:two, 10], :six)
  def fox_the_cubes(*vals)
    foxed_cubes = vals.map { |v| FoxedCube.new(v) }
    @game.instance_variable_set(:@cubes, foxed_cubes)
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

    def pick_value_for_sun(cubes, turn_points)
      @when_asked_about_the_sun.call(cubes, turn_points)
    end

    def when_asked_about_the_sun(&block)
      @when_asked_about_the_sun = block
    end

  end
  
  class SilentTurnView
    def start_turn(player)
    end
    
    def cubes_tossed(cubes)
    end
    
    def end_turn(player, points)
    end
    
    def game_over(winner)
    end
    
    def starting_last_licks
    end
      
    def too_many_points(player)
    end
    
    def instant_winner(player)
    end
  end
  
  class FixedScorer
    def initialize(score_results)
      @results = score_results
    end
    
    def score(cubes, game)
      @results
    end
  end
end
