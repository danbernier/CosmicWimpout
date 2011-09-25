require 'highline'

module CosmicWimpout

  class PlayerView < Player
  
    def initialize(name)
      super(name)
      @hl = HighLine.new
    end
    
    def toss_again?(cubes, turn_points)
      raise 'not done'
    end
    
    def pick_value_for_sun(cubes, turn_points)
      raise 'not done'
    end
  
  end

end
