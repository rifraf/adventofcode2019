#
# Advent of Code 2019 day 24
#
require 'pp'
require 'test/unit'
require_relative '../intcode/intcode'

#===========================================================
# Test driver24a
#===========================================================
class Examples24a < Test::Unit::TestCase
  #=========================================================
  def test_4_evolutions
    initial = [
      '....#',
      '#..#.',
      '#..##',
      '..#..',
      '#....'
    ]
    minute1 = [
      '#..#.',
      '####.',
      '###.#',
      '##.##',
      '.##..'
    ]
    minute4 = [
      '####.',
      '....#',
      '##..#',
      '.....',
      '##...'
    ]
    surface = Surface.new(initial)
    assert_equal initial, surface.to_a
    assert_equal minute1, surface.evolve!.to_a
    assert_equal minute4, surface.evolve!.evolve!.evolve!.to_a
  end

  def test_biodiversity_value
    # To understand the nature of the bugs, watch for the first time a layout of bugs
    # and empty spaces matches any previous layout. In the example above, the first
    # layout to appear twice is:
    #
    # .....
    # .....
    # .....
    # #....
    # .#...
    #
    # To calculate the biodiversity rating for this layout, consider each tile left-to-right
    # in the top row, then left-to-right in the second row, and so on. Each of these
    # tiles is worth biodiversity points equal to increasing powers of two: 1, 2, 4, 8, 16, 32,
    # and so on. Add up the biodiversity points for tiles with bugs; in this example,
    # the 16th tile (32768 points) and 22nd tile (2097152 points) have bugs,
    # a total biodiversity rating of 2129920.
    example = [
      '.....',
      '.....',
      '.....',
      '#....',
      '.#...'
    ]
    surface = Surface.new(example)
    assert_equal 2129920, surface.biodiversity
  end

  #=========================================================
  def test_part1
    initial = IO.readlines('input.txt')
    surface = Surface.new(initial)
    bios = [surface.biodiversity]

    loop do
      b = surface.evolve!.biodiversity
      if bios.include?(b)
        puts "Duplicate biodiversity #{b}"
        assert_equal 32506911, b # <- Correct
        break
      end
      bios << b
    end
  end
end

#===========================================================
class Surface
  #=========================================================
  def initialize(text_array)
    @grid = []
    5.times { @grid << [nil, nil, nil, nil, nil] }
    text_array.each_with_index do |line, y|
      x = 0
      line.each_char do |c|
        @grid[y][x] = 1 if c == '#'
        x += 1
      end
    end
  end

  #=========================================================
  def evolve!
    nextgen = []
    5.times do |y|
      nextgen << []
      5.times do |x|
        nextgen[y] << _next_gen(@grid, x, y)
      end
    end
    @grid = nextgen
    self
  end

  #=========================================================
  def biodiversity
    val = 0
    incr = 1
    @grid.each do |l|
      l.each do |v|
        val += incr if v
        incr <<= 1
      end
    end
    val
  end

  #=========================================================
  def to_a
    ret = []
    5.times do |y|
      ret << @grid[y].map { |i| i.nil? ? '.' : '#' }.join
    end
    ret
  end

  #=========================================================
  def _next_gen(grid, x, y)
    adj = _adjacent_bugs(grid, x, y)
    if grid[y][x]
      # Bug
      (adj == 1) ? 1 : nil
    else
      # Empty
      ((adj == 1) || (adj == 2)) ? 1 : nil
    end
  end

  #=========================================================
  def _adjacent_bugs(grid, x, y)
    adjacent_count = 0
    adjacent_count += 1 if (y > 0) && grid[y - 1][x]
    adjacent_count += 1 if (y < 4) && grid[y + 1][x]
    adjacent_count += 1 if (x > 0) && grid[y][x - 1]
    adjacent_count += 1 if (x < 4) && grid[y][x + 1]
    adjacent_count
  end
end
