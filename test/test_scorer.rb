require 'test_helper'

module FixedCube
  def initialize(face)
    @face_up = face
  end

  def toss
    @face_up
  end

  def count_as(value)
    @face_up = value
  end
  
  def self.cube(face)
    case face
      when FixedCube
        face
      else
        White.new(face)
    end
  end
end

class White < CosmicWimpout::WhiteCube
  include FixedCube
end

class Black < CosmicWimpout::BlackCube
  include FixedCube
end

class MockGame < CosmicWimpout::Game

  attr_reader :calls
  def initialize
    @calls = []
  end

  def ask_which_flash_to_complete(faces)
    @calls << faces
    faces.sort_by(&:to_s).first
  end
  
  def sun=(value)
    @sun = [value]
  end
  
  def ask_how_to_count_sun(cubes)
    @sun.pop
  end
  
end

class TestScorer < MiniTest::Unit::TestCase

  include CosmicWimpout

  def setup
    @game = MockGame.new
  end
  
  def score(*faces)
    faces = Array(faces).flatten.shuffle
    cubes = faces.map { |f| FixedCube.cube(f) }
    CosmicWimpout::Scorer.new.score(cubes, @game)
  end
  
  def pair(item)
    [item, item]
  end

  def test_five_of_a_kinds
    assert_equal :too_many_points, score(5.oak 10)
    assert_equal :instant_winner, score(5.oak :six)
    assert_equal FreightTrain.new(points: 500), score(5.oak 5)
    assert_equal FreightTrain.new(points: 400), score(5.oak :four)
    assert_equal FreightTrain.new(points: 300), score(5.oak :three)
    assert_equal FreightTrain.new(points: 200), score(5.oak :two)
  end
  
  def test_four_of_a_kinds
    assert_equal Flash.new(points: 110, face: 10, remaining: [:six]), 
          score(4.oak(10), :six)
    assert_equal Flash.new(points: 110, face: 10, remaining: []), 
          score(4.oak(10))
    
    assert_equal Flash.new(points: 25, face: :two, remaining: [:two]), 
          score(4.oak(:two), 5)
    assert_equal Flash.new(points: 20, face: :two, remaining: [:two]), 
          score(4.oak(:two))
    
    assert_equal Flash.new(points: 115, face: 10, remaining: []), 
          score(4.oak(10), 5)
    assert_equal Flash.new(points: 110, face: 10, remaining: []), 
          score(4.oak(10))
    
    assert_equal Flash.new(points: 20, face: :two, remaining: [:four, :two]),
                 score(4.oak(:two), :four)
    assert_equal Flash.new(points: 20, face: :two, remaining: [:two]),
                 score(4.oak(:two))
  end
  
  def test_three_of_a_kinds
    assert_equal Flash.new(points: 50, face: 5, remaining: [:three, :two]), 
          score(3.oak(5), :two, :three)
    assert_equal Flash.new(points: 50, face: 5, remaining: [:two]), 
          score(3.oak(5), :two)
    assert_equal Flash.new(points: 50, face: 5, remaining: []), 
          score(3.oak(5))
    
    assert_equal Flash.new(points: 45, face: :four, remaining: [:two]), 
          score(3.oak(:four), :two, 5)
    assert_equal Flash.new(points: 40, face: :four, remaining: [:two]), 
          score(3.oak(:four), :two)
    assert_equal Flash.new(points: 40, face: :four, remaining: []), 
          score(3.oak(:four))
    
    assert_equal Flash.new(points: 75, face: :six, remaining: []), 
          score(3.oak(:six), 10, 5)
    assert_equal Flash.new(points: 65, face: :six, remaining: []), 
          score(3.oak(:six), 5)
    assert_equal Flash.new(points: 60, face: :six, remaining: []), 
          score(3.oak(:six))
  end
  
  def test_two_pair_and_sun
  
    assert_equal Flash.new(points: 60, face: 5, remaining: []), 
          score(pair(5), pair(10), :sun)
    
    assert_equal [5, 10], @game.calls.pop.sort
    
    assert_equal Flash.new(points: 60, face: :six, remaining:[:two, :two]), 
          score(pair(:two), pair(:six), :sun)
          
    assert_equal [:six, :two], @game.calls.pop.sort
    
    # two pair w/o sun counts as 4 symbols
  end
  
  def test_one_pair_and_sun
  
    assert_equal Flash.new(points: 50, face: 5, remaining: [:four, :two]), 
          score(pair(5), :sun, :two, :four)
    assert_equal Flash.new(points: 50, face: 5, remaining: [:six]), 
          score(pair(5), :sun, :six)
    assert_equal Flash.new(points: 50, face: 5, remaining: []), 
          score(pair(5), :sun)
    
    assert_equal Flash.new(points: 30, face: :three, remaining: [:four, :two]), 
          score(pair(:three), :sun, :two, :four)
    assert_equal Flash.new(points: 40, face: :three, remaining: []), 
          score(pair(:three), :sun, 10)
    assert_equal Flash.new(points: 30, face: :three, remaining: []), 
          score(pair(:three), :sun)
  end
  
  def test_stuff_with_sun
    
    @game.sun = 10
    points = score(:two, 5, 10, :sun, :six)
    assert_equal Points, points.class
    assert_equal 25, points.points
    assert_equal [:six, :two], points.remaining.map(&:face_up)
    
    @game.sun = 10
    points = score(:sun, :two, :three)
    assert_equal Points, points.class
    assert_equal 10, points.points
    assert_equal [:three, :two], points.remaining.map(&:face_up)
    
    @game.sun = :four
    assert_equal :wimpout, score(:sun, :two, :three)
    
  end
  
  def test_scored_numbers
    assert_equal Points.new(points: 25, remaining: [:three, :two]), 
          score(pair(10), 5, :two, :three)
    assert_equal Points.new(points: 15, remaining: []), score(5, 10)
    assert_equal Points.new(points: 10, remaining: [:three, :two, :two]), 
          score(:two, 10, :two, :three)
    assert_equal Points.new(points: 5, remaining: []), score(5)
    assert_equal Points.new(points: 30, remaining: [:six]), 
          score(pair(10), pair(5), :six)
    assert_equal Points.new(points: 15, remaining: [:four, :four, :three]), 
          score(5, 10, pair(:four), :three)
    assert_equal Points.new(points: 10, remaining: [:four, :four, :six]), 
          score(pair(5), pair(:four), :six)
    assert_equal Points.new(points: 5, remaining: [:six, :three]), 
          score(5, :three, :six)
  end
  
  def test_wimpout
    pool = [:two, :three, :four, :six] * 2
    
    30.times do
      1.upto(5) do |n|
        assert_equal :wimpout, score(pool.shuffle.take(n))
      end
    end
  end

end

class Integer
  def oak(val) # oak = short for Of A Kind. 3.oak(5) -> [5, 5, 5]
    [val] * self
  end
end
