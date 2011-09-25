module CosmicWimpout

  class Controller
    
    def self.start
      self.new.start
    end
    
    def initialize(deps)
      @view = deps[:view] || View.new
    end
    
    def start
      players = @view.gather_players.map { |name| PlayerView.new(name) }
      max_points = @view.ask_the_game_limit
      @game = Game.new(max_points, players)
      
    end
    
  end

end
