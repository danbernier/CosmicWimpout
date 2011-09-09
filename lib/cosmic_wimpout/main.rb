module CosmicWimpout

  class Game
    attr_reader :current_player

    def initialize(*player_names)
      players = player_names.map { |name| Player.new(name) }
      @players = players.cycle

      @cubes = [Cube.new(:two, :three, :four, 5, :six, 10)] * 4
      @cubes.push Cube.new(:two, :sun, :four, 5, :six, 10)

      start_next_turn
    end

    # TODO this might go away, once the game is smart enough to end a turn on its own.
    def end_turn
      @current_player.bank_points @turn_points
      start_next_turn
    end

    private
    def start_next_turn
      @turn_points = 0
      @current_player = @players.next
    end
  end

  class Player
    attr_reader :name, :points
    def initialize(name)
      @name = name
      @points = 0
    end

    def to_s
      "Player #{@name}, #{@points} points"
    end

    def bank_points(new_points)
      @points += new_points
    end
  end

  class Cube
    def initialize(*sides)
      @sides = sides
    end
  end

end
