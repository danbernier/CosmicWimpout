require_relative 'player'
require_relative 'cube'

module CosmicWimpout

  class Game
  
    attr_reader :players, :max_points

    def initialize(max_points, players)
      @max_points = max_points
      @players = players
      @cubes = Array.new(4) { WhiteCube.new } + [BlackCube.new]
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

        if unscored_cubes.any?(&:tossed_the_sun?)
          sun_value = current_player.pick_value_for_sun(unscored_cubes, turn_points)
          black_cube = unscored_cubes.find(&:tossed_the_sun?)
          black_cube.count_as(sun_value)
        end

        scored_cubes, unscored_cubes, toss_points = *score_cubes(unscored_cubes)

        turn_points += toss_points

        if scored_cubes.empty? # Cosmic Wimpout! End of turn.
          end_turn
          return

        elsif unscored_cubes.empty?
          unscored_cubes = @cubes

        # TODO Bug? Was YMNWTBYM, w/ 0 banked points, and wasn't asked.
        # It effectively answered 'bank the points.'
        elsif player_quits(current_player, unscored_cubes, turn_points)
          end_turn(:and_bank => turn_points)
          return

        end

        # Now toss the left-over cubes!
      end
    end

    def score_cubes(unscored_cubes)

      when_three_of_a_kind(unscored_cubes) do |flash_cubes|

        flash_score = 10 * value_of_face(flash_cubes.first.face_up)

        return add_up_number_cubes(unscored_cubes - flash_cubes).tap do |array|
          array[2] += flash_score
          array[0] += flash_cubes
        end
      end

      add_up_number_cubes(unscored_cubes)
    end

    def add_up_number_cubes(unscored_cubes)
      numbers, symbols = unscored_cubes.partition(&:tossed_a_number?)
      toss_points = numbers.map(&:face_up).reduce(0, :+)
      [numbers, symbols, toss_points]
    end

    # TODO Scoring tosses might work better as a strategy object.
    # A class w/ a detector method, & a scorer method.
    def when_three_of_a_kind(cubes, &block)
      grouping = cubes.group_by(&:face_up)
      flash = grouping.find do |face, cubes|
        [3,4].include? cubes.size
      end

      if flash
        flash_face, flash_cubes = *flash
        flash_cubes = flash_cubes.take(3) # If 4-of-a-kind, the 4th counts normally.

        block.call(flash_cubes)
      end
    end

    # TODO This kind of thing makes me wonder whether we should kill the symbols.
    # (Of course this is the most painful part of using the symbols, so it would.)
    def value_of_face(face)
      symbols = { :two=>2, :three=>3, :four=>4, :six=>6 }
      if symbols.key? face
        symbols[face]
      else
        face
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
