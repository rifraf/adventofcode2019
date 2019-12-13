#
# Advent of Code 2019 day 10
#
require 'pp'
require 'test/unit'

#===========================================================
# Test driver10a
#===========================================================
class Examples10 < Test::Unit::TestCase
  def test_example1
    asteroid_map = [
      '.#..#',
      '.....',
      '#####',
      '....#',
      '...##'
    ]
    expected_visibility = [
      '.7..7',
      '.....',
      '67775',
      '....7',
      '...87'
    ]
    expected_asteroid_coords = {
      [1, 0] => "#",
      [4, 0] => "#",
      [0, 2] => "#",
      [1, 2] => "#",
      [2, 2] => "#",
      [3, 2] => "#",
      [4, 2] => "#",
      [4, 3] => "#",
      [3, 4] => "#",
      [4, 4] => "#"
    }
    expected_visibility_coords = {
      [1, 0] => "7",
      [4, 0] => "7",
      [0, 2] => "6",
      [1, 2] => "7",
      [2, 2] => "7",
      [3, 2] => "7",
      [4, 2] => "5",
      [4, 3] => "7",
      [3, 4] => "8",
      [4, 4] => "7"
    }

    # Strings to maps
    assert_equal expected_asteroid_coords, map_by_coordinates(asteroid_map)
    assert_equal expected_visibility_coords, map_by_coordinates(expected_visibility)

    # Create asteroid directory
    asteroid_locations = map_by_coordinates(asteroid_map).keys
    asteroids = asteroid_locations.map { |xy| Asteroid.new(xy) }

    # Find vector to each asteroid
    asteroids.each do |asteroid|
      pp [asteroid.location, asteroid.vectors_to(asteroid_locations)]
    end
  end
end

#===========================================================
class Asteroid

  attr_reader :location

  def initialize(location)
    @location = location
  end

  def vectors_to(locations)
    locations.map do |location|
      route_x = location[0] - @location[0]
      route_y = location[1] - @location[1]
      distance = Math.sqrt((route_x * route_x) + (route_y * route_y))
      [ distance, Float(route_x) / Float(route_y) ]
    end
  end
end

#===========================================================
def map_by_coordinates(string_map)
  map = {}
  y = 0
  string_map.each do |x_line|
    x_line.chars.each_with_index do |char, x|
      map[[x, y]] = char unless char == '.'
    end
    y += 1
  end
  map
end
