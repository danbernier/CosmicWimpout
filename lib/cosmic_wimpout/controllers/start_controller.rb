module CosmicWimpout
  module Controllers
  
    class StartController
      
      def self.start
        controller = self.new
        until controller == :stop
          controller = controller.start
        end
      end
      
      def initialize(deps={})
        @view = deps[:view] || Views::StartView.new
      end
      
      def start
        players = @view.gather_players.map do |name|
          Views::PlayerView.new(name)
        end
        max_points = @view.ask_the_game_limit
        TurnController.new(Game.new(max_points, players))
      end
      
    end
    
  end
end
