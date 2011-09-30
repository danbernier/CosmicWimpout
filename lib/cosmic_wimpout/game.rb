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

    def take_turn(deps={})

      raise 'Game is already over!' if over?

      turn_view.start_turn(current_player)

      turn_points = 0
      unscored_cubes = @cubes

      until unscored_cubes.empty?
        toss unscored_cubes

        scorer = deps[:scorer] || Scorer.new
        score = scorer.score(unscored_cubes, self)
        #p score

        case score
          when :too_many_points
            too_many_points
            return
          when :instant_winner
            instant_winner
            return
          when :wimpout
            end_turn
            return
          when FreightTrain
            turn_points += score.points
            unscored_cubes = @cubes
          when Flash
            turn_points += score.points
            @flash = score.face # TODO rename that to flash
            unscored_cubes = score.remaining
          when Points
            turn_points += score.points
            unscored_cubes = score.remaining
        end
        
        if unscored_cubes.empty?  # YMNWTBYM!
          unscored_cubes = @cubes
        elsif player_quits(current_player, unscored_cubes, turn_points)
          end_turn(:and_bank => turn_points)
          return
        end

        # Now toss the left-over cubes!
      end
      
    end
    
    def ask_which_flash_to_complete(pair_faces)
      turn_view.ask_which_flash_to_complete(pair_faces)
    end
    
    def too_many_points
      # TODO  add to the view
      puts "TOO Many points! #{current_player} is out of the game."
    end
    
    def instant_winner
      # TODO  add to the view
      puts "Instant Winner! #{current_player} just won the game."
      @we_had_an_instant_winner = true
    end
    
    def player_picks_sun(unscored_cubes, turn_points)
      current_player.pick_value_for_sun(unscored_cubes, turn_points)
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
      @we_had_an_instant_winner ||
      (
      !@last_licks_remaining_turns.nil? && @last_licks_remaining_turns.empty?
      )
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
