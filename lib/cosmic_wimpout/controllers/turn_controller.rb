module CosmicWimpout
  module Controllers
  
    class TurnController
    
      def initialize(game)
        @game = game
      end
      
      def start
        if @game.over?
          :stop
        else
          @game.take_turn
          self
        end
      end
      
    end
  
  end
end
