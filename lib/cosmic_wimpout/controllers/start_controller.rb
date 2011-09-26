module CosmicWimpout
  module Controllers
  
    class StartController
      
      def self.start
        next_controller = *self.new.start
        loop {
          next_controller = next_controller.start
        }
      end
      
      def initialize(deps)
        @view = deps[:view] || View.new
      end
      
      def start
        players = @view.gather_players.map { |name| PlayerView.new(name) }
        max_points = @view.ask_the_game_limit
        TurnController.new(Game.new(max_points, players))
      end
      
    end
    
  end
end
