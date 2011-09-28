module CosmicWimpout

  class Controller
    
    def self.start
      controller = self.new
      
      controller.start
      
      until controller.over?
        controller.take_turn
      end
    end
    
    attr_reader :game
    
    def initialize(deps={})
      @start_view = deps[:view] || Views::StartView.new
    end
    
    def start
    
      players = @start_view.gather_players.map do |name|
        Views::PlayerView.new(name)
      end
      
      max_points = @start_view.ask_the_game_limit
      
      @game = Game.new(max_points, players, CosmicWimpout::Views::TurnView.new)
    end
    
    
    def over?
      @game.over?
    end
    
    def take_turn
      @game.take_turn
    end
    
  end
  
end
