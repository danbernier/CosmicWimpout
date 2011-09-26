require 'minitest/autorun'
require 'minitest/mock'
require 'cosmic_wimpout'

describe CosmicWimpout::Controllers::TurnController do

  include CosmicWimpout

  it "should stop when the game is over" do
  
    turns_left = 5
    controller = Controllers::TurnController.new(MockGame.new(turns_left))
    
    turns_left.times do
      next_controller = controller.start
      next_controller.class.must_equal Controllers::TurnController
    end
    
    next_controller = controller.start
    next_controller.must_equal :stop
    
  end
  
  class MockGame
    def initialize(n)
      @number_of_turns = n
    end
    
    def over?
      @number_of_turns == 0
    end
    
    def take_turn
      @number_of_turns -= 1
    end
  end

end
