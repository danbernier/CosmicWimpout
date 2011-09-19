module CosmicWimpout

  # Craps calls them 'dice', Cosmic Wimpout calls them 'cubes'.
  # (At least we don't have the singular 'die' everywhere.)
  # Represents a six-sided cube. Die. You know, a d6.

  # The main things about a Cube are:
  # 1. What sides does it have? (White vs Black)
  # 2. What happens when it's tossed? (Fixed vs Normal)
  # Everything else should flow from there: ie, face_up, & tossed_a_number?.

  module Cube

    module ClassMethods
      attr_reader :sides

      def has_sides(*sides)
        @sides ||= sides
      end
    end

    module InstanceMethods
      attr_reader :face_up

      def toss!
        @face_up = self.class.sides.sample
      end

      def tossed_a_number?
        [5, 10].include? self.face_up
      end

      def black? # Currently, just for irb
        self.class.sides.include? :sun
      end
    end

    def self.included(klass)
      klass.module_eval do
        extend  ClassMethods
        include InstanceMethods
      end
    end
  end

  class WhiteCube
    include Cube
    has_sides :two, :three, :four, 5, :six, 10
  end

  class BlackCube
    include Cube
    has_sides :two, :sun, :four, 5, :six, 10
  end
end
