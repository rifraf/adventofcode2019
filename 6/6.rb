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
  attr_reader :name
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

  def route_to_centre
    return [] unless @orbits.any?

    [@orbits[0].name] + @orbits[0].route_to_centre
  end
end

def map_rocks(orbit_info)
  rock_directory = {}
  orbit_info.each do |orbit|
    inner, orbiter = orbit.split(')')
    rock_directory[inner] ||= Rock.new(inner)
    rock_directory[orbiter] ||= Rock.new(orbiter)
    rock_directory[orbiter].orbits(rock_directory[inner])
  end
  rock_directory
end

#===========================================================
def direct_and_indirect_orbits_for(orbit_info)
  rock_directory = map_rocks(orbit_info)

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

#===========================================================
# Test driver2
#===========================================================
class Examples2 < Test::Unit::TestCase
  def test_data
    orbits = ['COM)B', 'B)C', 'C)D', 'D)E', 'E)F', 'B)G', 'G)H', 'D)I', 'E)J', 'J)K', 'K)L', 'K)YOU', 'I)SAN']
    assert_equal 4, orbital_transfers_for(orbits, 'YOU', 'SAN')
  end
end

def route_to_centre(rock_directory, start)
  rock_directory[start].route_to_centre
end

def orbital_transfers_for(orbit_info, a, b)
  rock_directory = map_rocks(orbit_info)
  a_route_from_centre = route_to_centre(rock_directory, a).reverse
  b_route_from_centre = route_to_centre(rock_directory, b).reverse

  matches = a_route_from_centre & b_route_from_centre

  hops = (a_route_from_centre.length - matches.length) + (b_route_from_centre.length - matches.length)
  hops
end

#===========================================================
# Test driver2a
#===========================================================
class Examples2a < Test::Unit::TestCase
  def test_data
    orbits = IO.readlines('input1.txt').map { |l| l.strip }
    assert_equal 532, orbital_transfers_for(orbits, 'YOU', 'SAN') # <- correct solution
  end
end
