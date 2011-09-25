require 'highline'

module CosmicWimpout

  class View
  
    def initialize
      @hl = HighLine.new
    end
  
    def gather_players
      @hl.ask("Who's playing? (or a blank line to quit): ") do |q| 
        q.gather = ''
      end
    end
    
    def ask_the_game_limit
      @hl.ask("What should we play to?  ", Integer) { |q| q.in = 0..1000 }
    end
  
  end

end
