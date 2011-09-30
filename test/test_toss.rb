require 'test_helper'

describe CosmicWimpout::Toss do

  it "can detect groups of cubes with the same face" do
  
    toss = toss(:three, :three, :three, :three, :three)
    toss.groups_of_size(5).must_equal [:three]
    
    toss = toss(:four, :four, :four, :four)
    toss.groups_of_size(4).must_equal [:four]
    
    toss = toss(:two, :two, :six, :six, :three)
    toss.groups_of_size(2).must_equal [:two, :six]
    
  end
  
  it "can filter out cubes by face value" do
    toss = toss(:three, :four, 5)
    toss.filter_out(5).map(&:face_up).must_equal [:three, :four]
    
    toss = toss(5, 10, 5, :three, :six)
    toss.filter_out([:three, 5]).map(&:face_up).must_equal [10, :six]
  end
  
  it "knows whether it has numbers" do
    toss = toss(:three, :four, :six, :two)
    toss.has_numbers?.must_equal false
    
    toss = toss(5, :three, :four, :six, :two)
    toss.has_numbers?.must_equal true
  end
  
  it "knows whether it has the sun" do
    toss = toss(:three, :four, :six, :two)
    toss.has_sun?.must_equal false
    
    toss = toss(:sun, :three, :four, :six, :two)
    toss.has_sun?.must_equal true
  end
  
  def toss(*faces)
    CosmicWimpout::Toss.new(cubes(*faces))
  end
  
  def cubes(*faces)
    faces.map { |face| FoxedCube.new(face) }
  end

end
