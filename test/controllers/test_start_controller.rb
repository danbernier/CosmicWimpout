require 'minitest/autorun'
require 'minitest/mock'
require 'cosmic_wimpout'

describe CosmicWimpout::Controllers::StartController do

  include CosmicWimpout

  it "should start the game" do
  
    view = MiniTest::Mock.new
    view.expect(:gather_players, %w[Tortoise Achilles])
    view.expect(:ask_the_game_limit, 750)
    
    controller = Controllers::StartController.new(view: view)
    next_controller = controller.start
    
    game = next_controller.instance_variable_get(:@game)
    game.players.map(&:name).must_equal ['Tortoise', 'Achilles']
    game.max_points.must_equal 750
    
  end

end
