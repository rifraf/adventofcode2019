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
    location_and_visibility = []
    asteroids.each do |asteroid|
      other_asteroids = asteroid_locations.reject { |loc| loc == asteroid.location }
      angles = asteroid.polar_vectors_to(other_asteroids).map { |_distance, angle| angle }
      visible_asteroids = angles.uniq.count # If angle matches then only the first will be seen.
      # visible_asteroids = asteroid.visible_asteroids(other_asteroids)
      assert_equal visible_asteroids, asteroid.visible_asteroids(other_asteroids)
      assert_equal expected_visibility_coords[asteroid.location], visible_asteroids.to_s
      location_and_visibility << [asteroid.location, visible_asteroids]
    end

    best_location = location_and_visibility.max { |a, b| a[1] <=> b[1] }[0]
    assert_equal [3, 4], best_location
  end

  def test_example2
    asteroid_map = ['......#.#.', '#..#.#....', '..#######.', '.#.#.###..', '.#..#.....', '..#....#.#', '#..#....#.', '.##.#..###', '##...#..#.', '.#....####']
    # Best is 5,8 with 33 other asteroids detected:
    assert_equal [[5, 8], 33], best_monitoring_location(asteroid_map)
  end

  def test_example3
    asteroid_map = ['#.#...#.#.', '.###....#.', '.#....#...', '##.#.#.#.#', '....#.#.#.', '.##..###.#', '..#...##..', '..##....##', '......#...', '.####.###.']
    # Best is 1,2 with 35 other asteroids detected:
    assert_equal [[1, 2], 35], best_monitoring_location(asteroid_map)
  end

  def test_example4
    asteroid_map = ['.#..#..###', '####.###.#', '....###.#.', '..###.##.#', '##.##.#.#.', '....###..#', '..#.#..#.#', '#..#.#.###', '.##...##.#', '.....#.#..']
    # Best is 6,3 with 41 other asteroids detected
    assert_equal [[6, 3], 41], best_monitoring_location(asteroid_map)
  end

  def test_example5
    asteroid_map = [
      '.#..##.###...#######',
      '##.############..##.',
      '.#.######.########.#',
      '.###.#######.####.#.',
      '#####.##.#.##.###.##',
      '..#####..#.#########',
      '####################',
      '#.####....###.#.#.##',
      '##.#################',
      '#####.##.###..####..',
      '..######..##.#######',
      '####.##.####...##..#',
      '.#####..#.######.###',
      '##...#.##########...',
      '#.##########.#######',
      '.####.#.###.###.#.##',
      '....##.##.###..#####',
      '.#.#.###########.###',
      '#.#.#.#####.####.###',
      '###.##.####.##.#..##'
    ]
    # Best is 11,13 with 210 other asteroids detected
    assert_equal [[11, 13], 210], best_monitoring_location(asteroid_map)
  end

  def test_part1
    asteroid_map = [
      '#.#.##..#.###...##.#....##....###',
      '...#..#.#.##.....#..##.#...###..#',
      '####...#..#.##...#.##..####..#.#.',
      '..#.#..#...#..####.##....#..####.',
      '....##...#.##...#.#.#...#.#..##..',
      '.#....#.##.#.##......#..#..#..#..',
      '.#.......#.....#.....#...###.....',
      '#.#.#.##..#.#...###.#.###....#..#',
      '#.#..........##..###.......#...##',
      '#.#.........##...##.#.##..####..#',
      '###.#..#####...#..#.#...#..#.#...',
      '.##.#.##.........####.#.#...##...',
      '..##...#..###.....#.#...#.#..#.##',
      '.#...#.....#....##...##...###...#',
      '###...#..#....#............#.....',
      '.#####.#......#.......#.#.##..#.#',
      '#.#......#.#.#.#.......##..##..##',
      '.#.##...##..#..##...##...##.....#',
      '#.#...#.#.#.#.#..#...#...##...#.#',
      '##.#..#....#..##.#.#....#.##...##',
      '...###.#.#.......#.#..#..#...#.##',
      '.....##......#.....#..###.....##.',
      '........##..#.#........##.......#',
      '#.##.##...##..###.#....#....###.#',
      '..##.##....##.#..#.##..#.....#...',
      '.#.#....##..###.#...##.#.#.#..#..',
      '..#..##.##.#.##....#...#.........',
      '#...#.#.#....#.......#.#...#..#.#',
      '...###.##.#...#..#...##...##....#',
      '...#..#.#.#..#####...#.#...####.#',
      '##.#...#..##..#..###.#..........#',
      '..........#..##..#..###...#..#...',
      '.#.##...#....##.....#.#...##...##'
    ]
    assert_equal [[22, 28], 326], best_monitoring_location(asteroid_map) # <- correct
  end
end

#===========================================================
class Asteroid
  attr_reader :location

  def initialize(location)
    @location = location
  end

  def polar_vectors_to(locations)
    locations.map do |location|
      route_x = location[0] - @location[0]
      route_y = location[1] - @location[1]
      [Math.hypot(route_y, route_x), Math.atan2(route_y, route_x).round(8)] # Distance, angle to 8 dp
    end
  end

  def visible_asteroids(locations)
    angles = polar_vectors_to(locations).map { |_distance, angle| angle }
    visible_asteroids = angles.uniq.count # If angle matches then only the first will be seen.
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

#===========================================================
def best_monitoring_location(asteroid_map)
  # Create asteroid directory
  asteroid_locations = map_by_coordinates(asteroid_map).keys
  asteroids = asteroid_locations.map { |xy| Asteroid.new(xy) }

  # Find vector to each asteroid
  location_and_visibility = []
  asteroids.each do |asteroid|
    other_asteroids = asteroid_locations.reject { |loc| loc == asteroid.location }
    visible_asteroids = asteroid.visible_asteroids(other_asteroids)
    location_and_visibility << [asteroid.location, visible_asteroids]
  end

  best_location = location_and_visibility.max { |a, b| a[1] <=> b[1] }
end
