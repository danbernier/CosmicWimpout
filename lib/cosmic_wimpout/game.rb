require_relative 'player'
require_relative 'cube'

module CosmicWimpout

  class Game

    def initialize(max_points, *players)
      @max_points = max_points
      @players = players
      @cubes = Array.new(4) { Cube.new(:two, :three, :four, 5, :six, 10) }
      @cubes.push Cube.new(:two, :sun, :four, 5, :six, 10)
    end

    def current_player
      if in_last_licks?
        @last_licks_remaining_turns.first
      else
        @players.first
      end
    end

    def take_turn

      raise GameOverException if over?

      turn_points = 0
      unscored_cubes = @cubes

      until unscored_cubes.empty?
        toss unscored_cubes

        numbers, symbols = unscored_cubes.partition(&:tossed_a_number?)
        turn_points += numbers.map(&:face_up).reduce(0, :+)

        if numbers.empty? # Cosmic Wimpout! End of turn.
          end_turn
          return

        elsif symbols.empty?
          unscored_cubes = @cubes

        elsif player_quits(current_player, symbols, turn_points)
          end_turn(:and_bank => turn_points)
          return

        else
          unscored_cubes = symbols

        end

        # Now toss the left-over cubes!
      end
    end

    # end_turn
    # end_turn(:and_bank => 140)
    def end_turn(opts={})
      if opts.has_key? :and_bank
        current_player.bank_points(opts[:and_bank])
      end

      if should_start_last_licks?
        start_last_licks
      else
        move_to_next_player  # Start the next player's turn
      end

      if over?
        announce_winner
      end
    end

    def move_to_next_player
      if in_last_licks?
        @last_licks_remaining_turns.shift
      else
        @players.rotate!
      end
    end

    def should_start_last_licks?
      !in_last_licks? && @players.any? { |player| player.points >= @max_points }
    end

    def start_last_licks
      @last_licks_remaining_turns = @players[1..-1]
    end

    def in_last_licks?
      !@last_licks_remaining_turns.nil? && !@last_licks_remaining_turns.empty?
    end

    def over?
      !@last_licks_remaining_turns.nil? && @last_licks_remaining_turns.empty?
    end

    def player_quits(player, cubes_to_toss, turn_points)
      if player.points > 0
        # If player has points banked, he can choose to stop.
        !current_player.toss_again?(cubes_to_toss, turn_points)
      else
        # Else, he needs at least 35 points this turn to quit.
        turn_points >= 35
      end
    end

    def toss(cubes)
      cubes.each &:toss!
    end

    def announce_winner
      # Just a hook for subclasses (I know we don't really need this, but...)
    end

    def winning_player
      if over?
        @players.sort_by(&:points).last
      end
    end

  end

  class GameOverException < Exception
  end
end
