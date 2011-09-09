module CosmicWimpout

  class Game
    def initialize(*player_names)
      @players = player_names.map { |name| Player.new(name) }

      @cubes = [Cube.new(:two, :three, :four, 5, :six, 10)] * 4
      @cubes.push Cube.new(:two, :sun, :four, 5, :six, 10)

      start_next_turn
    end

    def current_player
      @players.first
    end

    # TODO this might go away, once the game is smart enough to end a turn on its own.
    def end_turn
      current_player.bank_points @turn_points
      @players.rotate!
      start_next_turn
    end

    def toss_cubes
      @cubes.each { |c| c.toss }
      @turn_points = @cubes.inject(0) do |sum, cube|
        sum + if [5, 10].include? cube.face_up
                cube.face_up
              else
                0
              end
      end
    end

    # Just a helper, for development
    def to_s
      @players * "\n"
    end

    private
    def start_next_turn
      @turn_points = 0
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
    attr_reader :face_up

    def initialize(*sides)
      @sides = sides
    end

    def toss
      @face_up = @sides.sample
    end
  end

end
