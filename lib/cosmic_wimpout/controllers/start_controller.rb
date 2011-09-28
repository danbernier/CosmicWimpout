module CosmicWimpout
  module Controllers
  
    class StartController
      
      def self.start
        controller = self.new
        
        controller.start
        
        until controller.over?
          controller.take_turn
        end
      end
      
      attr_reader :game
      
      def initialize(deps={})
        @view = deps[:view] || Views::StartView.new
      end
      
      def start
        players = @view.gather_players.map do |name|
          Views::PlayerView.new(name)
        end
        max_points = @view.ask_the_game_limit
        @game = Game.new(max_points, players)
        
        @view = CosmicWimpout::Views::TurnView.new
        @game.publish_to(@view)
      end
      
      def over?
        @game.over?
      end
      
      def take_turn
        @game.take_turn
      end
      
    end
    
  end
end
