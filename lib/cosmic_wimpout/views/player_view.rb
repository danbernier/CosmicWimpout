require 'highline'

module CosmicWimpout
  module Views

    class PlayerView < Player
    
      def initialize(name)
        super(name)
        @hl = HighLine.new
      end
      
      def toss_again?(cubes, turn_points)
        @hl.say ''
        @hl.say "> #{name}, you have #{turn_points} points this turn."
        @hl.say "> Do you want to toss these cubes?"
        @hl.say "> #{cubes.sort_by(&:to_s) * ', '}"

        @hl.ask("> Toss 'em? (y, n) ") { |q| q.in = %w[y n] } == 'y'
      end
      
      def pick_value_for_sun(cubes, turn_points)
        
        @hl.say ''
        @hl.say "> #{name}, you rolled a Flaming Sun!"
        @hl.say "> You rolled:"
        @hl.say "> #{cubes.sort_by(&:to_s) * ', '}"

        @hl.ask("> How do you want to count the sun?  ", Integer) do |q|
          q.in = [2,3,4,5,6,10]
        end
      end
    
    end

  end
end
