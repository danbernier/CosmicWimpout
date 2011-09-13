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

    def roll_again?(cubes, turn_points)
      true
    end
  end
end
