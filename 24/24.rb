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
        @nextgen[y] << _next_gen(x, y)
      end
    end
    self
  end

  #=========================================================
  def apply_next_generation!
    @grid = @nextgen
    self
  end

  #=========================================================
  def evolve!
    prepare_next_generation
    apply_next_generation!
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
  def _next_gen(x, y)
    adj = _adjacent_bugs(x, y)
    if @grid[y][x].zero?
      # Empty
      ((adj == 1) || (adj == 2)) ? 1 : 0
    else
      # Bug
      (adj == 1) ? 1 : 0
    end
  end

  #=========================================================
  def _adjacent_bugs(x, y)
    adjacent_count = 0
    adjacent_count += 1 if (y > 0) && !@grid[y - 1][x].zero?
    adjacent_count += 1 if (y < 4) && !@grid[y + 1][x].zero?
    adjacent_count += 1 if (x > 0) && !@grid[y][x - 1].zero?
    adjacent_count += 1 if (x < 4) && !@grid[y][x + 1].zero?
    adjacent_count
  end
end

#===========================================================
# Test driver24b
#===========================================================
class Examples24b < Test::Unit::TestCase
  #=========================================================
  def test_1_recursive_evolutions
    initial      = ['....#', '#..#.', '#..##', '..#..', '#....']
    minute1      = ['#..#.', '####.', '##..#', '##.##', '.##..']
    minute1_up   = ['.....', '..#..', '...#.', '..#..', '.....']
    minute1_down = ['....#', '....#', '....#', '....#', '#####']
    empty        = ['.....', '.....', '.....', '.....', '.....']

    evolution_count = 1
    surfaces_needed = 2 * evolution_count + 1
    surfaces = []
    surfaces_needed.times { |i| surfaces << RecursiveSurface.new(i) }
    surfaces[evolution_count].load_bugs(initial)

    assert_equal empty,   surfaces[0].to_a
    assert_equal initial, surfaces[1].to_a
    assert_equal empty,   surfaces[2].to_a

    surfaces[0].connect(nil, surfaces[1])
    (surfaces_needed - 2).times do |i|
      surfaces[i + 1].connect(surfaces[i + 0], surfaces[i + 2])
    end
    surfaces[surfaces_needed - 1].connect(surfaces[surfaces_needed - 2], nil)

    # puts
    # puts 'Initial'
    # surfaces.each(&:show)
    surfaces.each(&:prepare_next_generation)
    surfaces.each(&:apply_next_generation!)

    # puts "1 minute"
    # surfaces.each(&:show)

    assert_equal minute1_down, surfaces[2].to_a
    assert_equal minute1,      surfaces[1].to_a
    assert_equal minute1_up,   surfaces[0].to_a
  end

  #=========================================================
  def test_10_recursive_evolutions
    initial = ['....#', '#..#.', '#..##', '..#..', '#....']

    evolution_count = 10
    surfaces_needed = 2 * evolution_count + 1
    surfaces = []
    surfaces_needed.times { |i| surfaces << RecursiveSurface.new(i) }
    surfaces[evolution_count].load_bugs(initial)

    surfaces[0].connect(nil, surfaces[1])
    (surfaces_needed - 2).times do |i|
      surfaces[i + 1].connect(surfaces[i + 0], surfaces[i + 2])
    end
    surfaces[surfaces_needed - 1].connect(surfaces[surfaces_needed - 2], nil)

    # puts "0 minutes"
    # surfaces.each(&:show)

    10.times do
      surfaces.each(&:prepare_next_generation)
      surfaces.each(&:apply_next_generation!)
    end

    # puts "10 minutes"
    # surfaces.each(&:show)

    depthm5 = ['..#..', '.#.#.', '....#', '.#.#.', '..#..']
    depthm4 = ['...#.', '...##', '.....', '...##', '...#.']
    depthm3 = ['#.#..', '.#...', '.....', '.#...', '#.#..']
    depthm2 = ['.#.##', '....#', '....#', '...##', '.###.']
    depthm1 = ['#..##', '...##', '.....', '...#.', '.####']
    depth0  = ['.#...', '.#.##', '.#...', '.....', '.....']
    depth1  = ['.##..', '#..##', '....#', '##.##', '#####']
    depth2  = ['###..', '##.#.', '#....', '.#.##', '#.#..']
    depth3  = ['..###', '.....', '#....', '#....', '#...#']
    depth4  = ['.###.', '#..#.', '#....', '##.#.', '.....']
    depth5  = ['####.', '#..#.', '#..#.', '####.', '.....']

    assert_equal depthm5, surfaces[5].to_a
    assert_equal depthm4, surfaces[6].to_a
    assert_equal depthm3, surfaces[7].to_a
    assert_equal depthm2, surfaces[8].to_a
    assert_equal depthm1, surfaces[9].to_a
    assert_equal depth0, surfaces[10].to_a
    assert_equal depth1, surfaces[11].to_a
    assert_equal depth2, surfaces[12].to_a
    assert_equal depth3, surfaces[13].to_a
    assert_equal depth4, surfaces[14].to_a
    assert_equal depth5, surfaces[15].to_a

    assert_equal 99, surfaces.map(&:bug_count).reduce(:+)
  end

  #=========================================================
  def test_part2
    initial = IO.readlines('input.txt')

    evolution_count = 200
    surfaces_needed = 2 * evolution_count + 1
    surfaces = []
    surfaces_needed.times { |i| surfaces << RecursiveSurface.new(i) }
    surfaces[evolution_count].load_bugs(initial)

    surfaces[0].connect(nil, surfaces[1])
    (surfaces_needed - 2).times do |i|
      surfaces[i + 1].connect(surfaces[i + 0], surfaces[i + 2])
    end
    surfaces[surfaces_needed - 1].connect(surfaces[surfaces_needed - 2], nil)

    evolution_count.times do
      surfaces.each(&:prepare_next_generation)
      surfaces.each(&:apply_next_generation!)
    end

    puts "#{evolution_count} minutes"
    surfaces.each(&:show)

    assert_equal 2025, surfaces.map(&:bug_count).reduce(:+)
  end
end

#===========================================================
class NilClass # Monkeypatch
  #=========================================================
  def cell(x, y)
    0
  end
end

#===========================================================
class RecursiveSurface < Surface
  attr_reader :index

  #=========================================================
  def initialize(index)
    @index = index
    super(nil)
  end

  #=========================================================
  def show
    puts "#{@index}:"
    5.times do |y|
      print ' '
      @grid[y].each { |i| print(i.zero? ? '.' : '#') }
      puts
    end
  end

  #=========================================================
  def connect(down, up)
    @down = down
    @up = up
  end

  #=========================================================
  def bug_count
    total = 0
    5.times do |y|
      total += @grid[y].reduce(:+)
    end
    total
  end

  #=========================================================
  def cell(x, y)
    @grid[y][x]
  end

  #=========================================================
  def north(x, y)
    return north_up if [x,y] == [2,3]

    (0 == y) ?
      @down.cell(2, 1) :
      cell(x, y - 1)
  end

  #=========================================================
  def east(x, y)
    return east_up if [x,y] == [1,2]

    (4 == x) ?
      @down.cell(3, 2) :
      cell(x + 1, y)
  end

  #=========================================================
  def south(x, y)
    return south_up if [x,y] == [2,1]

    (4 == y) ?
      @down.cell(2, 3) :
      cell(x, y + 1)
  end

  #=========================================================
  def west(x, y)
    return west_up if [x,y] == [3,2]

    (0 == x) ?
      @down.cell(1, 2) :
      cell(x - 1, y)
  end

  #=========================================================
  def north_up
    @up.cell(0,4) + @up.cell(1,4) + @up.cell(2,4) + @up.cell(3,4) + @up.cell(4,4)
  end

  #=========================================================
  def east_up
    @up.cell(0,0) + @up.cell(0,1) + @up.cell(0,2) + @up.cell(0,3) + @up.cell(0,4)
  end

  #=========================================================
  def south_up
    @up.cell(0,0) + @up.cell(1,0) + @up.cell(2,0) + @up.cell(3,0) + @up.cell(4,0)
  end

  #=========================================================
  def west_up
    @up.cell(4,0) + @up.cell(4,1) + @up.cell(4,2) + @up.cell(4,3) + @up.cell(4,4)
  end

  #=========================================================
  def _adjacent_bugs(x, y)
    return 0 if [x, y] == [2,2]

    north(x, y) + east(x, y) + south(x, y) + west(x, y)
  end
end
