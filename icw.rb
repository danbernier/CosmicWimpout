$LOAD_PATH << 'lib'
Dir['lib/**/*.rb'].each { |f| load f }

# This entire file is just here to help with development. It's meant to be
# loaded in irb, again and again and again.

module CosmicWimpout

  # Implements to_s. I haven't yet decided whether this is the to_s for
  # everyone.
  class WhiteCube
    def to_s
      face_up.to_s
    end
  end

  class BlackCube
    def to_s
      "Black #{face_up}"
    end
  end


  module IrbVersion

    # An irb-playable subclass of CosmicWimpout::Game; uses irb to let you
    # know what's going on.
    class IrbGame < CosmicWimpout::Game

      def initialize(max_points, player_names)
        irb_players = player_names.map { |name| IrbPlayer.new(name) }
        super(max_points, irb_players)
      end

      def take_turn
        puts "#{@players * "\n"}"

        # Cache it: super() will change current_player.
        cp = current_player
        puts "#{cp.name}'s turn."

        orig_score = cp.points
        super
        new_score = cp.points
        if new_score > orig_score
          new_points = new_score - orig_score
          puts "#{cp.name} earned #{new_points} points this turn!"
        end

      end

      def toss(cubes)
        super(cubes)
        puts "Tossed: #{cubes.sort_by(&:to_s) * ', '}"
      end

      def start_last_licks
        puts "
        ---------------
        @ Last Licks! @
        ---------------
        ".gsub(/^\s+/, '')
      end

      def announce_winner
        winner = winning_player
        puts "Game Over! #{winner.name} wins with #{winner.points} points!"
      end

    end

    # Asks the player, in irb, how to decide certain game actions.
    class IrbPlayer < CosmicWimpout::Player

      def toss_again?(cubes, turn_points)
        puts
        puts "> #{@name}, you have #{turn_points} points so far this turn."
        puts "> Do you want to toss these cubes?"
        puts "> #{cubes.sort_by(&:to_s) * ', '}"

        answer = ask("> Toss 'em? (y, n) ")
        answer.downcase == 'y'
      end

      def pick_value_for_sun(cubes, turn_points)
        puts
        puts "> #{@name}, you rolled a Flaming Sun!"
        puts "> You rolled:"
        puts "> #{cubes.sort_by(&:to_s) * ', '}"

        answer = ask("> How do you want to count the sun? (2,3,4,5,6,10) ")
        answer.to_i
      end

      def ask(prompt)
        print(prompt)
        gets.strip
      end

    end
  end
end


def game_to(max_points, *names)
  names = ['Fred', 'Wilma'] if names.nil? || names.empty?
  CosmicWimpout::IrbVersion::IrbGame.new(max_points, names)
end

# Save typing - make it easier to reload the file, when it's changed.
def ld
  load('icw.rb')
end
