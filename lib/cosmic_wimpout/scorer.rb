require 'ostruct'

module CosmicWimpout

  class FreightTrain < OpenStruct; end
  class Flash < OpenStruct; end
  class Points < OpenStruct; end
  class TwoPairWithSun < OpenStruct; end
  class PairWithSun < OpenStruct; end
  
  class TossScorer
    attr_reader :cubes
    
    def initialize(cubes, game)
      @cubes = cubes
      @game = game
    end
    
    def faces
      @cubes.map(&:face_up)
    end
    
    # TODO i could add five_of_a_kind, four_of_a_kind, etc, and have them call    
    # groups_of_size, and pop the first off - that might help
    def groups_of_size(n, cubes)
      counts = cubes.group_by(&:face_up).map { |face, cubes| [face, cubes.size] }
      counts.select { |face, count| count == n }.map(&:first)
    end
    
    def filter(cubes, values)
      values = Array(values)
      cubes.reject { |cube| values.include? cube.face_up }
    end
    
    def sort(cubes)
      cubes.sort_by { |cube| cube.face_up.to_s }
    end
    
    def flash(flash_face, other_cubes)
    
      flash_points = 10 * face_value(flash_face)
      number_points, symbol_cubes = *add_up_numbers(other_cubes)
    
      Flash.new(points: flash_points + number_points, face: flash_face, 
                remaining: sort(symbol_cubes))
    end
    
    def add_up_numbers(cubes)
      symbol_cubes = filter(cubes, [5, 10])
      number_cubes = cubes - symbol_cubes
      
      [number_cubes.map(&:face_up).inject(0, :+), symbol_cubes]
    end

    # TODO This kind of thing makes me wonder whether we should kill the symbols.
    # (Of course this is the most painful part of using the symbols, so it would.)
    def face_value(face)
      symbols = { :two=>2, :three=>3, :four=>4, :six=>6 }
      if symbols.key? face
        symbols[face]
      else
        face
      end
    end
    
  end
  
  class FiveOfAKind < TossScorer
  
    def can_score?
      @five_of_a_kind = groups_of_size(5, cubes).first
      !@five_of_a_kind.nil?
    end
    
    def score
      case @five_of_a_kind
        when 10
          :too_many_points
        when :six
          :instant_winner
        else
          FreightTrain.new(points: 100 * face_value(@five_of_a_kind))
      end
    end
    
  end
  
  # TODO check for a sun, & handle it as a 5oak
  class FourOfAKind < TossScorer
  
    def can_score?
      @four_of_a_kind = groups_of_size(4, cubes).first
      !@four_of_a_kind.nil?
    end
    
    def score
      # TODO auto-exclude the black, if it's in there, and a symbol. Be nice.
      four_of_a_kind_cube = cubes.select { |c| c.face_up == @four_of_a_kind }.first
      
      other_cube = filter(cubes, @four_of_a_kind)
      flash(@four_of_a_kind, other_cube + [four_of_a_kind_cube])
    end
    
  end
  
  class ThreeOfAKind < TossScorer
  
    def can_score?
      @three_of_a_kind = groups_of_size(3, cubes).first
      !@three_of_a_kind.nil?
    end
    
    def score
      flash(@three_of_a_kind, filter(cubes, @three_of_a_kind))
    end
    
  end
  
  class PairsWithSun < TossScorer
    
    def can_score?
      if faces.include? :sun
        @pairs = groups_of_size(2, cubes)
        !@pairs.empty?
      end
    end
    
    def score
      other_cubes = filter(cubes, @pairs)
      pair_cubes = cubes - other_cubes
      
      if @pairs.size == 2
        sun_value = @game.ask_which_flash_to_complete(@pairs)
      else
        sun_value = @pairs.first
      end
      
      flash(sun_value, filter(cubes, [:sun, sun_value]))
    end
    
  end
  
  class NumbersButNoMagic < TossScorer
    
    def can_score?
      @numbers = filter(cubes, [:two, :three, :four, :six, :sun])
      !@numbers.empty?
    end
    
    def score
      points, symbol_cubes = add_up_numbers(cubes)
      Points.new(points: points, remaining: sort(symbol_cubes))
    end
    
  end
  
  class Scorer
  
    TOSS_SCORERS = [FiveOfAKind, FourOfAKind, ThreeOfAKind, 
        PairsWithSun, NumbersButNoMagic]
  
    def score(cubes, game)
    
      toss_scorers = TOSS_SCORERS.map { |ts| ts.new(cubes, game) }
      
      toss_scorer = toss_scorers.find(&:can_score?)
      return toss_scorer.score unless toss_scorer.nil?
      
      :wimpout
      
    end
  
  end

end
