module CosmicWimpout

  class Game
  
    attr_reader :players, :max_points, :cubes, :turn_view

    def initialize(max_points, players, turn_view)
      @max_points = max_points
      @players = players
      @turn_view = turn_view
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

      raise 'Game is already over!' if over?

      turn_view.start_turn(current_player)

      turn_points = 0
      unscored_cubes = @cubes

      until unscored_cubes.empty?
        toss unscored_cubes

        if unscored_cubes.any?(&:tossed_the_sun?)
          sun_value = player_picks_sun(unscored_cubes, turn_points)
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

        elsif player_quits(current_player, unscored_cubes, turn_points)
          end_turn(:and_bank => turn_points)
          return

        end

        # Now toss the left-over cubes!
      end
      
    end
    
    def player_picks_sun(unscored_cubes, turn_points)
      current_player.pick_value_for_sun(unscored_cubes, turn_points)
    end

    def score_cubes(unscored_cubes)

      when_three_of_a_kind(unscored_cubes) do |flash_face, flash_cubes|

        flash_score = 10 * value_of_face(flash_face)
        
        return add_up_number_cubes(unscored_cubes - flash_cubes).tap do |array|
          array[2] += flash_score
          array[0] += flash_cubes
        end
      end

      add_up_number_cubes(unscored_cubes)
    end

    def add_up_number_cubes(unscored_cubes)
      numbers, symbols = unscored_cubes.partition(&:tossed_a_number?)
      
      if numbers.empty?
        toss_points = 0
      else
        toss_points = numbers.map(&:face_up).inject(:+)
      end
      
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
        
        # Store it - player has to clear the flash. (See #toss.)
        @flash = flash_face
        
        flash_cubes = flash_cubes.take(3) # If 4-of-a-kind, the 4th counts normally.

        block.call(flash_face, flash_cubes)
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
        turn_view.end_turn(current_player, opts[:and_bank])
      else
        turn_view.end_turn(current_player, 0)
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
      turn_view.starting_last_licks
    end

    def in_last_licks?
      !@last_licks_remaining_turns.nil? && !@last_licks_remaining_turns.empty?
    end

    def over?
      !@last_licks_remaining_turns.nil? && @last_licks_remaining_turns.empty?
    end
    
    def flash?
      !@flash.nil?
    end

    def player_quits(player, cubes_to_toss, turn_points)
      return false if flash?
      
      # If player has points banked, he can choose to stop.
      # Else, he needs at least 35 points this turn to quit.
      
      if turn_points >= 35 || player.points > 0
        !player.toss_again?(cubes_to_toss, turn_points)
      else
        false
      end
    end

    def toss(cubes)
      cubes.each &:toss
      turn_view.cubes_tossed(cubes.map(&:face_up))
      
      while flash? && cubes.map(&:face_up).include?(@flash)
        cubes.each &:toss
        turn_view.cubes_tossed(cubes.map(&:face_up))
      end
      
      @flash = nil
    end

    def announce_winner
      turn_view.game_over(winning_player)
    end

    def winning_player
      if over?
        @players.sort_by(&:points).last
      end
    end

  end
end
