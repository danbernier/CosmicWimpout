require 'minitest/autorun'
require 'cosmic_wimpout'

class FoxedCube
  include CosmicWimpout::Cube

  def initialize(values)
    values = [values] unless Array === values
    @fixed_toss_values = values.cycle
    @face_up = values.first
  end

  def toss
    @face_up = @fixed_toss_values.next
  end

  def count_as(value)
    @face_up = value
  end

end

