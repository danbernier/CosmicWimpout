module CosmicWimpout

  class Player

    attr_reader :name, :points

    def initialize(name)
      @name = name
      @points = 0
    end

    def to_s
      "#{@name} has #{@points} points"
    end

    def bank_points(new_points)
      @points += new_points
    end

    # Sometimes, the player has to decide whether to re-toss the cubes.
    # Subclasses of Player should override this in some creative way.
    # For example, EagerPlayer might return true if turn_points > 45,
    # and TimidPlayer might return true if turn_points > 10.
    def toss_again?(cubes, turn_points)
      true
    end

  end
end
