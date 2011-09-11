$LOAD_PATH << 'lib'
require 'cosmic_wimpout'

module CosmicWimpout
  class Cube
    def to_s
      if black?
        "Black #{face_up}"
      else
        face_up.to_s
      end
    end
  end
end

class IrbGame < CosmicWimpout::Game
  def self.start
    IrbGame.new 'Dan', 'Mary'
  end

  def initialize *player_names
    super player_names.map { |name| IrbPlayer.new(name) }
  end

  def toss cubes
    super cubes
    puts "\nTossed: #{cubes * ', '}"
  end
end

class IrbPlayer < CosmicWimpout::Player
  def roll_again? cubes, turn_points
    puts
    puts "> #{@name}, you have #{turn_points} points so far this turn."
    puts "> Do you want to re-roll these cubes?"
    puts "> #{cubes * ', '}"

    answer = ask "> Roll 'em? (y, n) "
    answer.downcase == 'y'
  end

  def ask prompt
    print prompt
    gets.strip
  end
end

def ld
  load 'icw.rb'
end
