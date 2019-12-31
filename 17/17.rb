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
  def test_example
    example = "..#..........
..#..........
#######...###
#.#...#...#.#
#############
..#...#...#..
..#####...^.."

    map = Map.new
    map.add_image example.chars.map(&:ord)
    # map.draw

    assert_equal [[2, 2], [2, 4], [6, 4], [10, 4]], map.intersections
    assert_equal 76, map.intersections.map { |loc| loc[0] * loc[1] }.reduce(&:+)
  end

  # ========================================================
  def test_part1
    program = IO.read('input1.txt').split(',').map(&:to_i)

    output = []
    run_intcode([], output, *program)

    map = Map.new
    map.add_image output
    # map.draw

    intersections = map.intersections
    assert_equal [[14, 8], [16, 12], [24, 16], [26, 26], [16, 28], [22, 28], [12, 34], [14, 34], [2, 48], [10, 52], [12, 56]], intersections
    assert_equal 4600, intersections.map { |loc| loc[0] * loc[1] }.reduce(&:+) # <- correct
  end
end

#===========================================================
class Map
  NORTH = '^'.ord
  SOUTH = 'v'.ord
  WEST = '<'.ord
  EAST = '>'.ord

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
      when 'X'.ord # Fallen off
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
      break if distance.zero?

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
      raise "Missed _next_direction(#{direction}, #{position})"
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
    [steps, position]
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
    assert_equal 'R08R08R04R04R08L06L02R04R04R08R08R08L06L02', route_sequence
    assert_equal 'R8R8R4R4R8L6L2R4R4R8R8R8L6L2', _function_string(route_sequence)

    possibles = find_possible_programs(route_sequence)
    # pp [:possible_in_example, possibles]

    assert_true check_legal_program(possibles[0][0], possibles[0][1], possibles[0][2], possibles[0][3], 'R8R8R4R4R8L6L2R4R4R8R8R8L6L2')
    assert_true check_legal_program(possibles[1][0], possibles[1][1], possibles[1][2], possibles[1][3], 'R8R8R4R4R8L6L2R4R4R8R8R8L6L2')

    p2 = encode_program(possibles[1][0], possibles[1][1], possibles[1][2], possibles[1][3], 'n')
    expect2 = [
      65, 44, 66, 44, 67, 44, 66, 44, 65, 44, 67, 10,
      82, 44, 56, 44, 82, 44, 56, 10,
      82, 44, 52, 44, 82, 44, 52, 44, 82, 44, 56, 10,
      76, 44, 54, 44, 76, 44, 50, 10,
      110, 10
    ]
    assert_equal expect2, p2
  end

  # ========================================================
  def test_sequences
    poss = find_possible_sequences('R08', 'L02', 'R08R04R04R08L06L02R04R04R08R08R08L06')
    assert_equal ["A__R04R04A__L06C__R04R04A__A__A__L06"], poss
  end

  # ========================================================
  def test_part2
    program = IO.read('input1.txt').split(',').map(&:to_i)
    program[0] = 2 # 'Wake' the robot

    output = []
    run_intcode([], output, *program)

    map = Map.new
    map.add_image output
    # map.draw

    segments_in_route = map.turn_and_move_segments
    route_sequence = stringify_segments(segments_in_route)
    assert_equal 'L12L10R8L12R8R10R12L12L10R8L12R8R10R12L10R12R8L10R12R8R8R10R12L12L10R8L12R8R10R12L10R12R8', _function_string(route_sequence)

    # By hand:
    # L12L10R8L12R8R10R12L12L10R8L12R8R10R12L10R12R8L10R12R8R8R10R12L12L10R8L12R8R10R12L10R12R8
    # 7   AACCBAC
    # 19: A:L12L10R8L12R8R10R12
    # 8:  B:R8R10R12
    # 8:  C:L10R12R8
    # ABABCCBABC
    # 10  ABABCCBABC
    # 11: A:L12L10R8L12
    # 8:  B:R8R10R12
    # 8:  C:L10R12R8
    # ABABCCR8R10R12ABC
    # 10  ABABCCBABC
    # 11: A:L12L10R8
    # 8:  B:L12R8R10R12
    # 8:  C:L10R12R8
    # ABABCCBABC
    # C: L10R12R8
    # B: R8R10R12
    # A: L12L10R8L12

    # By program (Quite inefficient but gets there...)
    # possibles = find_possible_programs(route_sequence).flatten.reject(&:empty?)
    # p possibles
    # ->
    #   "L12L10R08L12", "R08R10R12", "L10R12R08", "ABABCCBABC",
    #   "L12L10R08L12R08R10R12", "R08R10R12", "L10R12R08", "AACCBAC"

    assert_true check_legal_program('L12L10R8L12', 'R8R10R12', 'L10R12R8', 'ABABCCBABC', 'L12L10R8L12R8R10R12L12L10R8L12R8R10R12L10R12R8L10R12R8R8R10R12L12L10R8L12R8R10R12L10R12R8')
    result = run_program('L12L10R8L12', 'R8R10R12', 'L10R12R8', 'ABABCCBABC', 'n')

    assert_equal 1113411, result # <- correct
  end
end

#===========================================================
def find_possible_programs(route_sequence)
  # R08R08R04R04R08L06L02R04R04R08R08R08L06L02 ->
  # Require A starts with R08 and C ends with L02.
  # Hope first and last segment are not the same. (They are not in the 2 examples.)
  # for a size = 1 to max
  #  for c size = 1 to max - a size (backwards)
  #    test a, c
  possibles = []
  limit = route_sequence.length
  (3...limit).step(3) do |a_size|
    a = route_sequence[0...a_size]
    (3...limit).step(3) do |c_size|
      next if a_size + c_size > limit

      c = route_sequence[limit - c_size..-1]
      # p [a, c]
      possible = find_programmable_routes(a, c, route_sequence)
      possibles += possible if possible
      break if possible # Found something
    end
  end
  possibles
end

#===========================================================
def find_programmable_routes(a, c, route_sequence)
  # Take off A and C from ends
  remainder = route_sequence.gsub(/^#{a}/, '').gsub(/#{c}$/, '')

  sequences_to_try = find_possible_sequences(a, c, remainder)
  return [] unless sequences_to_try

  routes = []
  sequences_to_try.each do |seq|
    unmatched_sequences = seq.gsub(/A_+/, ' ').gsub(/C_+/, ' ').strip.gsub(/\s+/, ' ').split(' ')
    next unless unmatched_sequences.any?  # Assume always a B

    b = unmatched_sequences.first
    next unless unmatched_sequences.all? { |s| s == b }

    full_seq = seq.gsub(/A_+/, 'A').gsub(/C_+/, 'C').gsub(b, "B")
    matched_sequence = "A#{full_seq}C".gsub(/_/, '')

    next unless _program_fits_in_memory(a, b, c, matched_sequence)

    routes << [_function_string(a), _function_string(b), _function_string(c), matched_sequence]
    break # At lest one legal route has been found
  end
  routes.any? ? routes : nil

end

#===========================================================
def find_possible_sequences(a, c, remainder)
  # p [:find_possible_sequences, a, c, remainder]
  # See where A might fit by stepping on 3 chars at a time
  possible_a_starts = []
  (0..remainder.length - a.length).step(3).each { |start| possible_a_starts << start if remainder[start...start + a.length] == a }
  # p [:a, possible_a_starts]
  return nil unless possible_a_starts.any?

  # See where C might fit by stepping on 3 chars at a time
  possible_c_starts = []
  (0..remainder.length - c.length).step(3).each { |start| possible_c_starts << start if remainder[start...start + c.length] == c }
  # p [:c, possible_c_starts]
  return nil unless possible_c_starts.any?

  # Could optimize by looking at only doing permutations for A's and C's that overlap, but
  # run the risk of not catching the ones where a region might be A or C swap
  sequences_to_try = []
  a_swap = 'A' + '_' * (a.length - 1)
  c_swap = 'C' + '_' * (c.length - 1)
  possible_a_starts.permutation.each do |a_starts|
    possible_c_starts.permutation.each do |c_starts|
      unmatched_sequences = remainder.dup
      a_starts.each do |start|
        a_range = start...start + a.length
        unmatched_sequences[a_range] = a_swap unless unmatched_sequences[a_range].include?('A')
      end
      c_starts.each do |start|
        c_range = start...start + c.length
        unmatched_sequences[c_range] = c_swap unless unmatched_sequences[c_range].include?('C')
      end
      sequences_to_try << unmatched_sequences unless sequences_to_try.include?(unmatched_sequences)
    end
  end
  sequences_to_try#.uniq
end

#===========================================================
def _program_fits_in_memory(a, b, c, matched_sequence)
  return false if _function_string(a).length > 20
  return false if _function_string(b).length > 20
  return false if _function_string(c).length > 20
  matched_sequence.length <= 20
end

#===========================================================
def _function_string(str)
  str.gsub(/0(\d)/, '\1') # Strip leading 0's
end

#===========================================================
def stringify_segments(seg_info)
  # 3 chars per to support distances up to 99
  seg_info.map { |dir, len| dir + ("%02d" % len) }.join
end


#===========================================================
def check_legal_program(a, b, c, matched_sequence, original)
  return false unless _program_fits_in_memory(a, b, c, matched_sequence)
  reconstituted = matched_sequence.gsub('A', a).gsub('B', b).gsub('C', c)
  reconstituted == original
end

#===========================================================
def encode_program(a, b, c, matched_sequence, indicator)
  chars = []
  matched_sequence.each_char.to_a.join(',').each_char { |c| chars << c.ord }
  chars << 10

  a.gsub(/(\D)/, '\1,').gsub(/(\d)(\D)/, '\1,\2').each_char { |c| chars << c.ord }
  chars << 10

  b.gsub(/(\D)/, '\1,').gsub(/(\d)(\D)/, '\1,\2').each_char { |c| chars << c.ord }
  chars << 10

  c.gsub(/(\D)/, '\1,').gsub(/(\d)(\D)/, '\1,\2').each_char { |c| chars << c.ord }
  chars << 10

  chars << indicator.ord
  chars << 10

  chars
end

#===========================================================
def run_program(a, b, c, matched_sequence, indicator)

  program = IO.read('input1.txt').split(',').map(&:to_i)
  program[0] = 2

  chars = encode_program(a, b, c, matched_sequence, indicator)
  output = []
  run_intcode(chars, output, *program)

  output[-1]  # Last output is result
end
