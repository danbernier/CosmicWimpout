module CosmicWimpout

  class Toss
    attr_reader :cubes
    
    def initialize(cubes)
      @cubes = cubes
    end
    
    def faces
      @cubes.map(&:face_up)
    end
    
    def has_sun?
      faces.include? :sun
    end
    
    def has_numbers?
      filter_out([:two, :three, :four, :six, :sun]).size > 0
    end
    
    def groups_of_size(n)
      counts = cubes.group_by(&:face_up).map { |face, cubes| [face, cubes.size] }
      counts.select { |face, count| count == n }.map(&:first)
    end
    
    def filter_out(values)
      values = Array(values)
      cubes.reject { |cube| values.include? cube.face_up }
    end
    
  end

end
