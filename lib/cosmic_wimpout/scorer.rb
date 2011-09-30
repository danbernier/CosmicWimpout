require 'ostruct'

module CosmicWimpout

  class FreightTrain < OpenStruct; end
  class Flash < OpenStruct; end
  class Points < OpenStruct; end
  class TwoPairWithSun < OpenStruct; end
  class PairWithSun < OpenStruct; end
  
  class TossScorer
  
    def initialize(game)
      @game = game
    end
    
    def flash(flash_face, other_cubes)
    
      flash_points = 10 * face_value(flash_face)
      number_points, symbol_cubes = *add_up_numbers(other_cubes)
    
      Flash.new(points: flash_points + number_points, face: flash_face, 
                remaining: sort(symbol_cubes))
    end
    
    def sort(cubes)
      cubes.sort_by { |cube| cube.face_up.to_s }
    end

    def face_value(face)
      symbols = { :two=>2, :three=>3, :four=>4, :six=>6 }
      if symbols.key? face
        symbols[face]
      else
        face
      end
    end
    
    def add_up_numbers(cubes)
      symbol_cubes = filter_out(cubes, [5, 10])
      number_cubes = cubes - symbol_cubes
      
      [number_cubes.map(&:face_up).inject(0, :+), symbol_cubes]
    end
    
    # TODO this is copied from Toss#filter_out, but it takes the cubes param.
    def filter_out(cubes, values)
      values = Array(values)
      cubes.reject { |cube| values.include? cube.face_up }
    end
    
  end
  
  class FiveOfAKind < TossScorer
  
    def can_score?(toss)
      @five_of_a_kind = toss.groups_of_size(5).first
      !@five_of_a_kind.nil?
    end
    
    def score(toss)
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
  
    def can_score?(toss)
      @four_of_a_kind = toss.groups_of_size(4).first
      !@four_of_a_kind.nil?
    end
    
    def score(toss)
      # TODO auto-exclude the black, if it's in there, and a symbol. Be nice.
      four_of_a_kind_cube = toss.cubes.
                      select { |c| c.face_up == @four_of_a_kind }.first
      
      other_cube = toss.filter_out(@four_of_a_kind)
      flash(@four_of_a_kind, other_cube + [four_of_a_kind_cube])
    end
    
  end
  
  class ThreeOfAKind < TossScorer
  
    def can_score?(toss)
      @three_of_a_kind = toss.groups_of_size(3).first
      !@three_of_a_kind.nil?
    end
    
    def score(toss)
      flash(@three_of_a_kind, toss.filter_out(@three_of_a_kind))
    end
    
  end
  
  class PairsWithSun < TossScorer
    
    def can_score?(toss)
      if toss.has_sun?
        @pairs = toss.groups_of_size(2)
        !@pairs.empty?
      end
    end
    
    def score(toss)
      other_cubes = toss.filter_out(@pairs)
      pair_cubes = toss.cubes - other_cubes
      
      if @pairs.size == 2
        sun_value = @game.ask_which_flash_to_complete(@pairs)
      else
        sun_value = @pairs.first
      end
      
      flash(sun_value, toss.filter_out([:sun, sun_value]))
    end
    
  end
  
  class NumbersButNoMagic < TossScorer
    
    def can_score?(toss)
      toss.has_numbers?
    end
    
    def score(toss)
      points, symbol_cubes = *add_up_numbers(toss.cubes)
      Points.new(points: points, remaining: sort(symbol_cubes))
    end
    
  end
  
  # TODO Scorer is basically a namespace. Where should its stuff go?
  class Scorer
  
    TOSS_SCORERS = [FiveOfAKind, FourOfAKind, ThreeOfAKind, 
        PairsWithSun, NumbersButNoMagic]
  
    def score(cubes, game)
    
      toss_scorers = TOSS_SCORERS.map { |ts| ts.new(game) }
      
      toss = Toss.new(cubes)
      
      toss_scorer = toss_scorers.find { |ts| ts.can_score? toss }
      return toss_scorer.score(toss) unless toss_scorer.nil?
      
      :wimpout
      
    end
  
  end

end
