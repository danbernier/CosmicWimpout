require 'minitest/autorun'
require 'minitest/mock'
require 'cosmic_wimpout'

describe CosmicWimpout::Controller do

  it "should start the game" do
    view = MiniTest::Mock.new
    view.expect(:gather_players, %w[Tortoise Achilles])
    view.expect(:ask_the_game_limit, 750)
    
    controller = CosmicWimpout::Controller.new(view: view)
    controller.start
    
    game = controller.instance_variable_get(:@game)
    game.players.map(&:name).must_equal ['Tortoise', 'Achilles']
    game.max_points.must_equal 750
    
  end

end
