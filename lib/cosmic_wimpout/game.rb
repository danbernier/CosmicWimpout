module CosmicWimpout

  class Game

    def initialize(*players)
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

        numbers, symbols = unscored_cubes.partition(&:rolled_number?)
        turn_points += numbers.map(&:face_up).reduce(0, :+)

        if numbers.empty? # Cosmic Wimpout! End of turn.
          @players.rotate!
          return

        elsif symbols.empty?
          unscored_cubes = @cubes

        elsif player_quits(current_player, symbols, turn_points)
          current_player.bank_points(turn_points)
          @players.rotate!
          return

        else
          unscored_cubes = symbols

        end

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

    def toss(cubes)
      cubes.each &:toss
    end

  end
end
