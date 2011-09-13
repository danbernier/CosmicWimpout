module CosmicWimpout
  class Cube
    attr_reader :face_up

    def initialize(*sides)
      @sides = sides
    end

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
