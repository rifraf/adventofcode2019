#
# Advent of Code 2019 day 17
#
require 'pp'
require 'test/unit'
require_relative '../intcode/intcode'

#===========================================================
# Test driver17a
#===========================================================
class Examples17a < Test::Unit::TestCase

  # ========================================================
  def xtest_example
    example = "..#..........
..#..........
#######...###
#.#...#...#.#
#############
..#...#...#..
..#####...^.."

    map = Map.new
    map.add_image example.chars.map(&:ord)
    map.draw

    assert_equal [[2, 2], [2, 4], [6, 4], [10, 4]], map.intersections
    assert_equal 76, map.intersections.map { |loc| loc[0] * loc[1] }.reduce(&:+)
  end

  # ========================================================
  def xtest_part1
    program = IO.read('input1.txt').split(',').map(&:to_i)

    output = []
    run_intcode([], output, *program)

    map = Map.new
    map.add_image output
    map.draw

    intersections = map.intersections
    assert_equal [[14, 8], [16, 12], [24, 16], [26, 26], [16, 28], [22, 28], [12, 34], [14, 34], [2, 48], [10, 52], [12, 56]], intersections
    assert_equal 4600, intersections.map { |loc| loc[0] * loc[1] }.reduce(&:+)  # <- correct
  end
end

#===========================================================
class Map

  NORTH = '^'.ord
  SOUTH = 'v'.ord
  WEST = '<'.ord
  EAST ='>'.ord
  p [NORTH, SOUTH, EAST, WEST]

  def initialize
    @scaffold_points = []
    @x_max = 0
    @y_max = 0
  end

  def intersections
    @scaffold_points.select do |loc|
      x = loc[0]
      y = loc[1]
      @scaffold_points.include?([x - 1, y]) &&
        @scaffold_points.include?([x + 1, y]) &&
        @scaffold_points.include?([x, y - 1]) &&
        @scaffold_points.include?([x, y + 1])
    end
  end

  def add_image(image)
    x = 0
    y = 0
    image.each do |pix|
      case pix
      when 10 # \n
        x = 0
        y += 1
      when 46 # '.'
        x += 1
      when 35 # '#'
        @scaffold_points << [x, y]
        x += 1
      when 'X'.ord  # Fallen off
        x += 1
      when NORTH, SOUTH, EAST, WEST # Droid
        @scaffold_points << [x, y]
        @droid_location = [x, y]
        @droid_direction = pix
        x += 1
      end
      @x_max = [x, @x_max].max
      @y_max = [y, @y_max].max
    end
  end

  def draw
    puts
    (0..@y_max).each do |y|
      (0..@x_max).each do |x|
        if @droid_location == [x, y]
          print @droid_direction.chr
        elsif @scaffold_points.include?([x, y])
          print '#'
        else
          print '.'
        end
      end
      puts
    end
    puts
  end

  def turn_and_move_segments
    position = @droid_location
    direction = @droid_direction

    segments = []
    loop do
      direction, turn = _next_direction(direction, position)
      distance, position = _next_distance(direction, position)
      break if distance == 0
      segments << [turn, distance]
    end
    segments
  end

  def _next_direction(direction, position)
    x = position[0]
    y = position[1]
    case direction
    when NORTH
      return EAST, 'R' if @scaffold_points.include?([x + 1, y])
      return WEST, 'L' if @scaffold_points.include?([x - 1, y])
    when SOUTH
      return EAST, 'L' if @scaffold_points.include?([x + 1, y])
      return WEST, 'R' if @scaffold_points.include?([x - 1, y])
    when EAST
      return NORTH, 'L' if @scaffold_points.include?([x, y - 1])
      return SOUTH, 'R' if @scaffold_points.include?([x, y + 1])
    when WEST
      return NORTH, 'R' if @scaffold_points.include?([x, y - 1])
      return SOUTH, 'L' if @scaffold_points.include?([x, y + 1])
    else
      fail "Missed _next_direction(#{direction}, #{position})"
    end
  end

  def _next_distance(direction, position)
    x = position[0]
    y = position[1]
    steps = 0
    case direction
    when NORTH
      steps += 1 while @scaffold_points.include?([x, y - steps - 1])
      position = [x, y - steps]
    when SOUTH
      steps += 1 while @scaffold_points.include?([x, y + steps + 1])
      position = [x, y + steps]
    when EAST
      steps += 1 while @scaffold_points.include?([x + steps + 1, y])
      position = [x + steps, y]
    when WEST
      steps += 1 while @scaffold_points.include?([x - steps - 1, y])
      position = [x - steps, y]
    else
      return [0, position]
    end
    return steps, position
  end
end

#===========================================================
# Test driver17b
#===========================================================
class Examples17b < Test::Unit::TestCase

  # For the examples, can traverse route by running in line until
  # there are no more in that direction then turning in the only
  # l/r direction that has scaffolding.
  # Can therefore break down into sections of 'turn/moves'

  # ========================================================
  def test_example
    example = "#######...#####
#.....#...#...#
#.....#...#...#
......#...#...#
......#...###.#
......#.....#.#
^########...#.#
......#.#...#.#
......#########
........#...#..
....#########..
....#...#......
....#...#......
....#...#......
....#####......"

    map = Map.new
    map.add_image example.chars.map(&:ord)
    map.draw

    segments_in_route = map.turn_and_move_segments
    route_sequence = stringify_segments(segments_in_route)
    assert_equal 'R8R8R4R4R8L6L2R4R4R8R8R8L6L2', route_sequence

# ..R4R4R8..R4R4..R8..
    # R8R8R4R4R8L6L2R4R4R8R8R8L6L2 ->
    # Require A starts with R8 and C ends with L2.
    # Hope first and last segment are not the same. (They are not in the 2 examples.)
    # for a size = 1 to max
    #  for c size = 1 to max - a size (backwards)
    #    test a, c
    possibles = find_possible_programs(route_sequence)
    pp possibles
    # limit = route_sequence.length
    # p limit
    # (2...limit).step(2) do |a_size|
    #   a = route_sequence[0...a_size]
    #   (2...limit).step(2) do |c_size|
    #     next if a_size + c_size > limit
    #     c = route_sequence[limit - c_size..-1]
    #     # p [a, c]
    #     possible = test_for_programmable_route(a, c, route_sequence)
    #     p possible if possible
    #   end
    # end
  end

  # ========================================================
  def test_part2
    program = IO.read('input1.txt').split(',').map(&:to_i)
    program[0] = 2 # 'Wake' the robot

    output = []
    run_intcode([], output, *program)

    map = Map.new
    map.add_image output
    map.draw

    segments_in_route = map.turn_and_move_segments
    # pp segments_in_route
    route_sequence = stringify_segments(segments_in_route)
    assert_equal 'L12L10R8L12R8R10R12L12L10R8L12R8R10R12L10R12R8L10R12R8R8R10R12L12L10R8L12R8R10R12L10R12R8', route_sequence

    possibles = find_possible_programs(route_sequence).flatten.reject { |x| x.empty? }
    p __LINE__
    pp possibles
    p __LINE__
  end
end

#===========================================================
def stringify_segments(seg_info)
  seg_info.map { |dir, len| "#{dir}#{len}" }.join
end

#===========================================================
def test_for_programmable_route(a, c, route_sequence)
  remainder = route_sequence.gsub(/^#{a}/, '').gsub(/#{c}$/, '')
# p [a,c,remainder]

  possible_a_starts = []
  (0..remainder.length - a.length).step(2).each { |start| possible_a_starts << start if remainder[start...start + a.length] == a }
  return nil unless possible_a_starts.any?
# p [:a, possible_a_starts]

  possible_c_starts = []
  (0..remainder.length - c.length).step(2).each { |start| possible_c_starts << start if remainder[start...start + c.length] == c }
  return nil unless possible_c_starts.any?
# p [:c, possible_c_starts]

  sequences_to_try = []
  possible_a_starts.permutation.each do |a_starts|
    possible_c_starts.permutation.each do |c_starts|
      unmatched_sequences = remainder.dup
      a_swap = 'A' + '_' * (a.length - 1)
      c_swap = 'C' + '_' * (c.length - 1)
      a_starts.each do |start|
        a_range = start...start + a.length
        unmatched_sequences[a_range] = a_swap unless unmatched_sequences[a_range].include?('A')
      end
      c_starts.each do |start|
        c_range = start...start + c.length
        unmatched_sequences[c_range] = c_swap unless unmatched_sequences[c_range].include?('C')
      end
      # puts " #{unmatched_sequences}"
      sequences_to_try << unmatched_sequences #.dup
    end
  end
  sequences_to_try.uniq!
# p [:sequences_to_try, sequences_to_try.uniq]
  routes = []
  sequences_to_try.each do |seq|
    unmatched_sequences = seq.gsub(/A_+/, ' ').gsub(/C_+/, ' ').strip.gsub(/\s+/, ' ').split(' ')
# p [:unmatched_sequences1, unmatched_sequences]
    next unless unmatched_sequences.any?  # Assume always a B
# p __LINE__
    b = unmatched_sequences.first
# p __LINE__
    next unless unmatched_sequences.all? { |s| s == b }
# p __LINE__
    full_seq = seq.gsub(/A_+/, 'A').gsub(/C_+/, 'C').gsub(b, "B")
    matched_sequence = "A#{full_seq}C".gsub(/_/, '')
    len = a.length + b.length + c.length + matched_sequence.length
# p [__LINE__, a, b, c, matched_sequence, len]
    next unless len <= 20
    routes << [a, b, c, matched_sequence]
# p [:x, matched_sequence]
  end
  return nil if routes.empty?
  return routes

#   unmatched_sequences = route_sequence.gsub(a, " ").gsub(c, " ").strip.gsub(/\s+/, ' ').split(' ')
#   # unmatched_sequences = route_sequence.gsub('A_', ' ').gsub('C_', ' ').strip.gsub(/\s+/, ' ').split(' ')
# p [:unmatched_sequences2, unmatched_sequences]
#   # unmatched_sequences = route_sequence.gsub(c, " ").gsub(a, " ").strip.gsub(/\s+/, ' ').split(' ')
#   return nil unless unmatched_sequences.any?  # Assume always a B
#   # p unmatched_sequences
#   b = unmatched_sequences.first
#   return nil unless unmatched_sequences.all? { |s| s == b }

#   matched_sequence = route_sequence.gsub(a, "A").gsub(b, "B").gsub(c, "C")
#   len = a.length + b.length + c.length + matched_sequence.length
#   # p len
#   return nil unless len <= 20
# p [:y, a, b, c, matched_sequence, len]
#   [a, b, c, matched_sequence]
end

#===========================================================
def find_possible_programs(route_sequence)
  possibles = []
  limit = route_sequence.length
  (2...limit).step(2) do |a_size|
    a = route_sequence[0...a_size]
    (2...limit).step(2) do |c_size|
      next if a_size + c_size > limit
      c = route_sequence[limit - c_size..-1]
      # p [a, c]
      possible = test_for_programmable_route(a, c, route_sequence)
      possibles += possible if possible
    end
  end
  possibles
end
