require 'highline'

module CosmicWimpout
  module Views
   
    class TurnView
    
      def initialize
        @hl = HighLine.new
      end
    
      def start_turn(player)
        @hl.say("\n#{player.name}, with #{player.points} points, tosses the cubes...")
      end
      
      def cubes_tossed(cubes)
        @hl.say("Tossed: #{cubes.map(&:to_s).join(', ')}")
      end
      
      def end_turn(player, points)
        @hl.say("#{player.name} banks #{points} points, for a total of #{player.points}.")
      end
      
      def game_over(winner)
        @hl.say("\n#{winner.name} wins the game with #{winner.points} points!")
      end
      
      def starting_last_licks
        @hl.say("\nStarting last licks!")
      end
      
      def too_many_points(player)
        @hl.say("TOO Many points! #{player.name} is out of the game.")
      end
      
      def instant_winner(player)
        @h1.say("Instant Winner! #{current_player} just won the game.")
      end
    
    end

  end
end
