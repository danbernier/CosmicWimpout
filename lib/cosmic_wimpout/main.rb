module CosmicWimpout

  class Game
    def initialize *players
      @players = players

      @cubes = Array.new(4) { Cube.new(:two, :three, :four, 5, :six, 10) }
      @cubes.push Cube.new(:two, :sun, :four, 5, :six, 10)
    end

    def current_player
      @players.first
    end

    def take_turn
      turn_points = 0
      unscored_cubes = @cubes

      until unscored_cubes.empty?
        toss unscored_cubes

        numbers, symbols = unscored_cubes.partition &:rolled_number?
        turn_points += numbers.map(&:face_up).reduce(0, :+)

        if numbers.empty? # Cosmic Wimpout! End of turn.
          @players.rotate!
          return

        elsif symbols.empty?
          current_player.bank_points turn_points
          @players.rotate!
          return

        elsif player_quits(current_player, symbols, turn_points)
          current_player.bank_points turn_points
          @players.rotate!
          return
        end

        unscored_cubes = symbols
        # Now re-roll!
      end
    end

    def player_quits(player, cubes_to_toss, turn_points)
      if player.points > 0
        # If player has points banked, he can choose to stop.
        !current_player.roll_again?(cubes_to_toss, turn_points)
      else
        # Else, he needs at least 35 points this turn to quit.
        turn_points >= 35
      end
    end

    def toss cubes
      cubes.each &:toss
    end

    # Just a helper, for development
    def to_s
      @players * "\n"
    end
  end

  class Player
    attr_reader :name, :points
    def initialize name
      @name = name
      @points = 0
    end

    def to_s
      "Player #{@name}, #{@points} points"
    end

    def bank_points new_points
      @points += new_points
    end

    def roll_again? cubes, turn_points
      true
    end
  end

  class Cube
    attr_reader :face_up

    def initialize *sides
      @sides = sides
    end

    def toss
      @face_up = @sides.sample
    end

    def rolled_number?
      [5, 10].include? self.face_up
    end

    def black?
      @sides.include? :sun
    end
  end

end
