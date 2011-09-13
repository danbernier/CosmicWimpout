module CosmicWimpout

  # Craps calls them 'dice', Cosmic Wimpout calls them 'cubes'.
  # (At least we don't have the singular 'die' everywhere.)
  # Represents a six-sided cube. Die. You know, a d6.

  # TODO might consider giving Cube a class-method for defining the sides,
  # and having WhiteCube < Cube(:two, :three, :four, 5, :six, 10),
  # and BlackCube < Cube(:two, :sun, :four, 5, :six, 10).
  # That might make the whole 'black?' stuff clearer.

  class Cube

    attr_reader :face_up

    def initialize(*sides)
      @sides = sides
    end

    # TODO rename this to toss! ?
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
