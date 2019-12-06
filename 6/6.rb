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
    orbits = ['COM)B', 'B)C', 'C)D', 'D)E', 'E)F', 'B)G', 'G)H', 'D)I', 'E)J', 'J)K', 'K)L']
    assert_equal 42, direct_and_indirect_orbits_for(orbits)
  end
end

#===========================================================
class Rock
  def initialize(name)
    @name = name
    @orbits = []
  end

  def orbits(rock)
    @orbits << rock
  end

  def direct_orbits
    @orbits.length
  end

  def total_orbits
    return 0 unless @orbits.any?

    @total_orbits ||= @orbits.map do |rock|
      1 + rock.total_orbits
    end
    @total_orbits[0]
  end
end

#===========================================================
def direct_and_indirect_orbits_for(orbit_info)
  rock_directory = {}
  orbit_info.each do |orbit|
    inner, orbiter = orbit.split(')')
    rock_directory[inner] ||= Rock.new(inner)
    rock_directory[orbiter] ||= Rock.new(orbiter)
    rock_directory[orbiter].orbits(rock_directory[inner])
  end

  # pp rock_directory
  total = 0
  rock_directory.each do |_name, rock|
    total += rock.total_orbits
  end
  total
end

#===========================================================
# Test driver1a
#===========================================================
class Examples1a < Test::Unit::TestCase
  def test_data
    orbits = IO.readlines('input1.txt').map { |l| l.strip }
    assert_equal 387356, direct_and_indirect_orbits_for(orbits) # <- correct solution
  end
end
