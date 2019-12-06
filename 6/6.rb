#
# Advent of Code 2019 day 6
#
require 'pp'
require 'test/unit'

#===========================================================
# Test driver1
#===========================================================
class Examples1 < Test::Unit::TestCase
  def test_example1
    orbits = [
      'COM)B',
      'B)C',
      'C)D',
      'D)E',
      'E)F',
      'B)G',
      'G)H',
      'D)I',
      'E)J',
      'J)K',
      'K)L'
    ]
    assert_equal [3500,9,10,70,2,3,11,0,99,30,40,50], direct_and_indirect_orbits_for()([], [], 1,9,10,3,2,3,11,0,99,30,40,50)
  end

end
