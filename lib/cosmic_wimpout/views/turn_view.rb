require 'highline'

module CosmicWimpout
  module Views
   
    class TurnView
    
      def initialize
        @hl = HighLine.new
      end
    
      def start_turn(player)
        @hl.say("#{player.name}, with #{player.points} points, tosses the cubes...")
      end
      
      def end_turn(player, points)
        @hl.say("#{player.name} banks #{points} points.")
      end
      
      def game_over(winner)
        @hl.say("#{winner.name} wins the game with #{winner.points} points!")
      end
    
    end

  end
end
