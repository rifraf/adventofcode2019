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
  def initialize(text_array = nil)
    @grid = []
    5.times { @grid << [0, 0, 0, 0, 0] }
    load_bugs(text_array) if text_array
  end

  #=========================================================
  def load_bugs(text_array)
    text_array.each_with_index do |line, y|
      x = 0
      line.each_char do |c|
        @grid[y][x] = (c == '#') ? 1 : 0
        x += 1
      end
    end
  end

  #=========================================================
  def prepare_next_generation
    @nextgen = []
    5.times do |y|
      @nextgen << []
      5.times do |x|
        @nextgen[y] << _next_gen(@grid, x, y)
      end
    end
    self
  end

  #=========================================================
  def evolve!
    prepare_next_generation
    @grid = @nextgen
    self
  end

  #=========================================================
  def biodiversity
    val = 0
    incr = 1
    @grid.each do |l|
      l.each do |v|
        val += incr unless v.zero?
        incr <<= 1
      end
    end
    val
  end

  #=========================================================
  def to_a
    ret = []
    5.times do |y|
      ret << @grid[y].map { |i| i.zero? ? '.' : '#' }.join
    end
    ret
  end

  #=========================================================
  def _next_gen(grid, x, y)
    adj = _adjacent_bugs(grid, x, y)
    if grid[y][x].zero?
      # Empty
      ((adj == 1) || (adj == 2)) ? 1 : 0
    else
      # Bug
      (adj == 1) ? 1 : 0
    end
  end

  #=========================================================
  def _adjacent_bugs(grid, x, y)
    adjacent_count = 0
    adjacent_count += 1 if (y > 0) && !grid[y - 1][x].zero?
    adjacent_count += 1 if (y < 4) && !grid[y + 1][x].zero?
    adjacent_count += 1 if (x > 0) && !grid[y][x - 1].zero?
    adjacent_count += 1 if (x < 4) && !grid[y][x + 1].zero?
    adjacent_count
  end
end

#===========================================================
# Test driver24b
#===========================================================
class Examples24b < Test::Unit::TestCase
  #=========================================================
  def test_1_recursive_evolutions
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
    minute1_up = [
      '.....',
      '.....',
      '.....',
      '.....',
      '.....'
    ]
    minute1_down = [
      '.....',
      '.....',
      '.....',
      '.....',
      '.....'
    ]

    evolution_count = 1
    surfaces_needed = 2 * evolution_count + 1
    surfaces = []
    surfaces_needed.times { surfaces << RecursiveSurface.new }
    surfaces[evolution_count].load_bugs(initial)

    empty = [
      '.....',
      '.....',
      '.....',
      '.....',
      '.....'
    ]
    assert_equal empty,   surfaces[0].to_a
    assert_equal initial, surfaces[1].to_a
    assert_equal empty,   surfaces[2].to_a

    surfaces[0].connect(nil, surfaces[1])
    surfaces[1].connect(surfaces[0], surfaces[2])
    surfaces[2].connect(surfaces[1], nil)

    surfaces.each(&:prepare_next_generation)
    surfaces.each(&:evolve!)

    assert_equal minute1_down, surfaces[0].to_a
    assert_equal minute1,      surfaces[1].to_a
    assert_equal minute1_up,   surfaces[2].to_a
  end
end

#===========================================================
class RecursiveSurface < Surface
  def connect(down, up)
    @down = down
    @up = up
  end

  #=========================================================
  def _adjacent_bugs(grid, x, y)
    puts "_adjacent_bugs(grid, #{x}, #{y}) / #{@down} / #{@up}"
    adjacent_count = 0

    # TODO
    # adjacent_count += 1 if (y > 0) && !grid[y - 1][x].zero?
    # adjacent_count += 1 if (y < 4) && !grid[y + 1][x].zero?
    # adjacent_count += 1 if (x > 0) && !grid[y][x - 1].zero?
    # adjacent_count += 1 if (x < 4) && !grid[y][x + 1].zero?
    adjacent_count
  end
end
