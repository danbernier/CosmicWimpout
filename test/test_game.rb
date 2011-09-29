require 'minitest/autorun'
require 'cosmic_wimpout'

# minitest info: http://bfts.rubyforge.org/minitest/

describe CosmicWimpout::Game do

  before do
    @tortoise = MockPlayer.new "Tortoise"
    @achilles = MockPlayer.new "Achilles"
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

  describe "when the Flaming Sun is tossed" do
    it "should ask the player how to count it" do
      fox_the_cubes :two, :three, :four, :six, :sun
      was_asked = false
      @tortoise.when_asked_about_the_sun { was_asked = true; 10 }

      @game.take_turn

      was_asked.must_equal true
    end
  end

  describe "when the player tosses three-of-a-kind" do
    it "should score them 10x the points of that face" do

      @tortoise.points = 100
      @achilles.points = 100

      # 3 5s = 5*10
      fox_the_cubes 5, 5, 5, :two, [:four, 10]
      @game.take_turn
      @tortoise.points.must_equal 50 + 10 + 100 # 100 original points

      # 3 6s = 6*10. Yes, it works for symbols, too!
      fox_the_cubes :six, :six, :six, :two, [:four, 5]
      @achilles.tosses_if { false } # A rare moment of caution for Achilles.
      @game.take_turn
      @achilles.points.must_equal 60 + 5 + 100 # 100 original points
    end
  end
  describe "when the player tosses four-of-a-kind" do
    it "should score them 10x the points of that face" do

      @tortoise.points = 100
      @achilles.points = 100

      # 3 2s = 2*10. The extra :two is worthless.
      fox_the_cubes :two, :two, :two, [:two, 5], :four
      @game.take_turn
      
      # 20=flash, 5=lastcube, 100 original points
      @tortoise.points.must_equal 20 + 5 + 100

      # 3 5s = 5*10. The extra 5 counts for 5.
      fox_the_cubes [5,         10], 
                    [5,         :three], 
                    [5,         :six], 
                    [5,         :six], 
                    [:four, 10, :two]
      @achilles.tosses_if { false } # A rare moment of caution for Achilles.
      @game.take_turn
      @achilles.points.must_equal 50 + 5 + 10 + 10 + 100 # 100 original points
    end
  end
  describe "when the player tosses two-of-a-kind, and a sun" do
    it "should score them 10x the points of that face, if they allocate the sun right" do

      @tortoise.points = 100

      fox_the_cubes :two, :two, :six, [:three, 5], :sun
      @tortoise.when_asked_about_the_sun { :two } # Thus giving him 3 :twos.
      @game.take_turn
      @tortoise.points.must_equal 20 + 5 + 100 # 100 original points

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
  
  describe 'when a flash was tossed' do
    it 'should keep re-rolling until the flash is cleared' do
    
      @game.instance_variable_set(:@flash, :two)
      fox_the_cubes(:three, :four, :six, 5, [:two, :two, :two, :two, :four])
      
      counting_mock = CountingMock.new
      @game.instance_variable_set(:@turn_view, counting_mock)
      
      @game.toss(@game.cubes)
      
      counting_mock.count.must_equal(5)
      @game.flash?.must_equal false
    end
    
    
    it 'forces the player to re-roll' do
      @tortoise.points = 100
      
      fox_the_cubes(:two, :two, :two, 5, [:three, :two, :two, :two, :four])
      
      @game.take_turn
      @tortoise.points.must_equal 100
    end
    
    it 'forces the player to re-roll on YMNWTBYM' do
      @tortoise.points = 100
      
      fox_the_cubes([:three, :three, :three, :six,   :two],
                    [:three, :four,  :four,  :four,  :two],
                    [:three, :four,  :four,  :four,  :four],
                    [5,      :six,   :six,   :three, :six],
                    [10,     :two,   :two,   :two,   :four])
      
      @game.take_turn
      @tortoise.points.must_equal 100
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

  class FoxedCube
    include CosmicWimpout::Cube

    def initialize(values)
      values = [values] unless Array === values
      @fixed_toss_values = values.cycle
    end

    def toss
      @face_up = @fixed_toss_values.next
    end

    def count_as(value)
      @face_up = value
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

    def pick_value_for_sun(cubes, turn_points)
      @when_asked_about_the_sun.call(cubes, turn_points)
    end

    def when_asked_about_the_sun(&block)
      @when_asked_about_the_sun = block
    end

  end
  
  class CountingMock
    attr_reader :count
    
    def cubes_tossed(*args)
      @count = (@count || 0) + 1
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
  end
end
