#
# Advent of Code 2019 day 10
#
require 'pp'
require 'test/unit'

#===========================================================
# Test driver10a
#===========================================================
class Examples10a < Test::Unit::TestCase
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
      assert_equal visible_asteroids, asteroid.visible_asteroid_count(other_asteroids)
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
    result = best_monitoring_location(asteroid_map)
    assert_equal [[22, 28], 326], result # <- correct
    puts "Part 1 result = #{result[1]}"
  end
end

#===========================================================
class Asteroid
  attr_reader :location

  def initialize(location)
    @location = location
  end

  def polar_vector_to(location)
    # 0 is straight up
    route_x = location[0] - @location[0]
    route_y = location[1] - @location[1]
    [Math.hypot(route_y, route_x), Math.atan2(-route_x, route_y).round(8)] # Distance, angle to 8 dp
  end

  def polar_vectors_to(locations)
    locations.map do |location|
      polar_vector_to(location)
    end
  end

  def visible_asteroids(locations)
    locations_for_angle = {}
    locations.map do |location|
      vec = polar_vector_to(location)
      distance = vec[0]
      angle = vec[1]
      angle = -Math::PI if angle == Math::PI.round(8) # So up is -PI (first)
      locations_for_angle[angle] ||= []
      locations_for_angle[angle] << [location, distance]
    end
    angles = locations_for_angle.keys.sort
    # pp angles
    angles.map do |angle|
      angle_info = locations_for_angle[angle]
      closest = angle_info.min { |a, b| a[1] <=> b[1]}
      # pp closest, angle
      closest[0]
    end
  end

  def visible_asteroid_count(locations)
    angles = polar_vectors_to(locations).map { |_distance, angle| angle }
    angles.uniq.count # If angle matches then only the first will be seen.
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
    visible_asteroids = asteroid.visible_asteroid_count(other_asteroids)
    location_and_visibility << [asteroid.location, visible_asteroids]
  end

  location_and_visibility.max { |a, b| a[1] <=> b[1] }
end

#===========================================================
# Test driver10b
#===========================================================
class Examples10b < Test::Unit::TestCase
  def test_example1b
    asteroid_map = [
      '.#....#####...#..',
      '##...##.#####..##',
      '##...#...#.#####.',
      '..#.....#...###..',
      '..#.#.....#....##'
    ]
    assert_equal [[8,3], 30], best_monitoring_location(asteroid_map)

    asteroid_locations = map_by_coordinates(asteroid_map).keys
    asteroid = Asteroid.new([8,3])

    other_asteroids = asteroid_locations.reject { |loc| loc == asteroid.location }

    # First pass - delete all visible
    zapped_asteroids = asteroid.visible_asteroids(other_asteroids)

    first9 = [[8,1], [9,0], [9,1], [10,0], [9,2], [11,1], [12,1], [11,2], [15,1]]
    assert_equal first9, zapped_asteroids[0...9]

    second9 = [[12,2], [13,2], [14,2], [15,2], [12,3], [16,4], [15,4], [10,4], [4,4]]
    assert_equal second9, zapped_asteroids[9...18]

    third9 = [[2,4], [2,3], [0,2], [1,2], [0,1], [1,1], [5,2], [1,0], [5,1]]
    assert_equal third9, zapped_asteroids[18...27]

    final = [[6,1], [6,0], [7,0]]
    assert_equal final, zapped_asteroids[27...30]

    remaining_asteroids = other_asteroids - zapped_asteroids

    # Second pass - delete all visible
    zapped_asteroids = asteroid.visible_asteroids(remaining_asteroids)
    assert_equal [[8, 0], [10, 1], [14, 0], [16, 1], [13, 3]], zapped_asteroids

    remaining_asteroids -= zapped_asteroids

    # Third pass - delete all visible
    zapped_asteroids = asteroid.visible_asteroids(remaining_asteroids)
    assert_equal [[14, 3]], zapped_asteroids

    remaining_asteroids -= zapped_asteroids
    assert_equal [], remaining_asteroids
  end

  def test_part2
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

    asteroid_locations = map_by_coordinates(asteroid_map).keys
    asteroid = Asteroid.new([22, 28])

    other_asteroids = asteroid_locations.reject { |loc| loc == asteroid.location }

    # First pass - delete all visible
    zapped_asteroids = asteroid.visible_asteroids(other_asteroids)

    # We know there are 326, so grab the 200th
    location_of_200th = zapped_asteroids[199]
    result = location_of_200th[0] * 100 + location_of_200th[1]
    puts "Part 2 result = #{result}"

    assert_equal 1623, result
  end
end
