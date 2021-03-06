#
# Advent of Code 2019 day 15
#
require 'pp'
require 'test/unit'
require_relative '../intcode/intcode'

#===========================================================
# Test driver15a
#===========================================================
class Examples15a < Test::Unit::TestCase

  #=========================================================
  def test_simple_movement
    map = MapOfShip.new
    navigator = DummyNavigator.new([Navigator::WALL, Navigator::WALL, Navigator::WALL, Navigator::MOVED, Navigator::FOUND_OXYGEN, Navigator::WALL])
    droid = Droid.new(navigator)

    # Initial
    assert_equal [], map.oxygen_location
    assert_equal [], map.walls
    assert_equal [0, 0], droid.position

    # Head bang 1
    response, location = droid.move(Navigator::NORTH)
    assert_equal Navigator::WALL, response
    assert_equal [0, 0], droid.position

    map.add_wall location
    assert_equal [[0, 1]], map.walls

    # Head bang 2
    response, location = droid.move(Navigator::SOUTH)
    assert_equal Navigator::WALL, response
    assert_equal [0, 0], droid.position

    map.add_wall location
    assert_equal [[0, 1], [0, -1]], map.walls

    # Head bang 3
    response, location = droid.move(Navigator::EAST)
    assert_equal Navigator::WALL, response
    assert_equal [0, 0], droid.position

    map.add_wall location
    assert_equal [[0, 1], [0, -1], [1, 0]], map.walls

    # Movement
    response, _location = droid.move(Navigator::WEST)
    assert_equal Navigator::MOVED, response
    assert_equal [-1, 0], droid.position

    # Movement - oxygen
    response, location = droid.move(Navigator::WEST)
    assert_equal Navigator::FOUND_OXYGEN, response
    assert_equal [-2, 0], droid.position

    map.add_oxygen location
    assert_equal [[-2, 0]], map.oxygen_location

    # Head bang 4
    response, location = droid.move(Navigator::WEST)
    assert_equal Navigator::WALL, response
    assert_equal [-2, 0], droid.position

    map.add_wall location
    assert_equal [[0, 1], [0, -1], [1, 0], [-3, 0]], map.walls

    # map.visualize_with_droid droid.position
  end

  #=========================================================
  def test_exploring_part1
    program = IO.read('input1.txt').split(',').map(&:to_i)
    map = MapOfShip.new
    navigator = Navigator.new(program)
    droid = Droid.new(navigator)

    # ----------------------------------------
    # Work out walls with random walk
    # No good for the second part because it
    # doesn't explore the complete space
    # ----------------------------------------
    # loop do
    #   response, location = droid.move([Navigator::NORTH, Navigator::SOUTH, Navigator::EAST, Navigator::WEST].sample)
    #   case response
    #   when Navigator::FOUND_OXYGEN
    #     map.add_oxygen location
    #     print 'O'
    #     break
    #   when Navigator::WALL
    #     map.add_wall location
    #     print 'W'
    #   else
    #     print '.'
    #   end
    #   # print "#{location} "
    # end
    # # Save result
    # IO.write('walls', map.walls.to_s)
    # IO.write('oxygen', map.oxygen_location.to_s)

    # ----------------------------------------
    # Read map back from file
    # ----------------------------------------
    eval(IO.read('oxygen')).each { |loc| map.add_oxygen loc }
    eval(IO.read('walls')).each { |loc| map.add_wall loc }

    # Answer is 248 (by hand - see 'map')
    # map.visualize_with_droid droid.position
  end
end

#===========================================================
class MapOfShip
  attr_reader :oxygen_location
  attr_reader :walls

  # --------------------------------------------------------
  def initialize
    @oxygen_location = []
    @walls = []
    @colored = {}
  end

  # --------------------------------------------------------
  def add_wall(loc)
    @walls << loc
  end

  # --------------------------------------------------------
  def add_oxygen(loc)
    @oxygen_location << loc
  end

  # --------------------------------------------------------
  def color(locations, value)
    locations.each do |loc|
      @colored[loc] = value
    end
  end

  # --------------------------------------------------------
  def occupied?(loc)
    @colored[loc] || @walls.include?(loc) || !@x_range.cover?(loc[0]) || !@y_range.cover?(loc[1])
  end

  # --------------------------------------------------------
  def freeze_dimensions
    x_coords = @walls.map { |x, _y| x }.sort.uniq
    y_coords = @walls.map { |_x, y| y }.sort.uniq
    @x_range = (x_coords[0]..x_coords[-1])
    @y_range = (y_coords[0]..y_coords[-1])
  end

  # --------------------------------------------------------
  def visualize_with_droid(droid_loc)
    cells = {
      [0, 0] => 'Z',
      droid_loc => 'D'
    }
    @walls.each { |pos| cells[pos] = '#' }
    @oxygen_location.each { |pos| cells[pos] = 'O' }
    x_coords = cells.keys.map { |x, _y| x }.sort.uniq
    y_coords = cells.keys.map { |_x, y| y }.sort.uniq
    puts
    (y_coords[0]..y_coords[-1]).reverse_each do |y|
      (x_coords[0]..x_coords[-1]).each do |x|
        print cells[[x, y]] || '.'
      end
      puts
    end
    puts
  end

  # --------------------------------------------------------
  def visualize_colorized
    cells = {}
    @walls.each { |pos| cells[pos] = '#' }
    @colored.each { |loc, val| cells[loc] = '~' }
    puts
    freeze_dimensions
    @y_range.reverse_each do |y|
      @x_range.each do |x|
        print cells[[x, y]] || '.'
      end
      puts
    end
    puts
  end

  # --------------------------------------------------------
  def paint_adjacent_to(seekers, value)
    new_seekers = []

    seekers.each do |loc|
      x = loc[0]
      y = loc[1]
      new_seekers << [x + 1, y] unless occupied?([x + 1, y])
      new_seekers << [x - 1, y] unless occupied?([x - 1, y])
      new_seekers << [x, y + 1] unless occupied?([x, y + 1])
      new_seekers << [x, y - 1] unless occupied?([x, y - 1])
    end
    color(new_seekers, value)

    new_seekers
  end

end

#===========================================================
class DummyNavigator
  # --------------------------------------------------------
  def initialize(responses)
    @responses = responses
  end

  # --------------------------------------------------------
  def response_to_move(_move)
    @responses.shift
  end
end

#===========================================================
class FakeNavigator
  # --------------------------------------------------------
  def initialize(walls)
    @walls = walls
    @x = 0
    @y = 0
  end

  # --------------------------------------------------------
  def response_to_move(move)
    next_pos = [@x + 1, @y] if move == Navigator::EAST
    next_pos = [@x - 1, @y] if move == Navigator::WEST
    next_pos = [@x, @y + 1] if move == Navigator::NORTH
    next_pos = [@x, @y - 1] if move == Navigator::SOUTH
    return Navigator::WALL if @walls.include?(next_pos)

    @x = next_pos[0]
    @y = next_pos[1]
    Navigator::MOVED
  end
end

#===========================================================
class Navigator
  NORTH = 1
  SOUTH = 2
  WEST = 3
  EAST = 4

  WALL = 0
  MOVED = 1
  FOUND_OXYGEN = 2

  # --------------------------------------------------------
  def initialize(program)
    @input = Queue.new
    @output = Queue.new

    threads = []
    threads << Thread.new do
      run_intcode(@input, @output, *program)
    end
  end

  # --------------------------------------------------------
  def response_to_move(move)
    @input << move
    @output.pop
  end
end

#===========================================================
class Droid
  attr_reader :position

  # --------------------------------------------------------
  def initialize(navigator)
    @position = [0, 0]
    @navigator = navigator
  end

  # --------------------------------------------------------
  def move(step)
    next_position = case step
                    when Navigator::NORTH
                      [@position[0], @position[1] + 1]
                    when Navigator::SOUTH
                      [@position[0], @position[1] - 1]
                    when Navigator::WEST
                      [@position[0] - 1, @position[1]]
                    when Navigator::EAST
                      [@position[0] + 1, @position[1]]
                    end
    response = @navigator.response_to_move(step)
    @position = next_position unless response == Navigator::WALL
    [response, next_position]
  end
end

#===========================================================
# Test driver15b
#===========================================================
class Examples15b < Test::Unit::TestCase

  # Try tending right but going left when hitting a wall.
  # Should work if the map is enclosed (else oxygen will leak). May miss walls
  # not connected to others by > 1 grid

  #=========================================================
  def test_simple_search
    map = MapOfShip.new
    navigator = FakeNavigator.new([[0,1], [-1,1], [-1,0], [-1,-1], [0,-1], [1,-1], [1,0],  [1,1] ])
    droid = Droid.new(navigator)

    # Initial
    assert_equal [], map.oxygen_location
    assert_equal [], map.walls
    assert_equal [0, 0], droid.position

    direction = Navigator::NORTH
    6.times do
      response, location = droid.move(direction)
      break if location == map.walls.first
      if response ==  Navigator::WALL
        map.add_wall location
        # Go left
        direction = case direction
                    when Navigator::NORTH then Navigator::WEST
                    when Navigator::SOUTH then Navigator::EAST
                    when Navigator::WEST  then Navigator::SOUTH
                    when Navigator::EAST  then Navigator::NORTH
                    end
      end
      # map.visualize_with_droid droid.position
    end

  end

  #=========================================================
  def test_exploring_part2
    program = IO.read('input1.txt').split(',').map(&:to_i)
    map = MapOfShip.new
    navigator = Navigator.new(program)
    droid = Droid.new(navigator)
    location = [0, 0]

    direction = Navigator::NORTH
    loop do
      response, location = droid.move(direction)
      if response ==  Navigator::WALL
        map.add_wall location
        # Go left
        direction = case direction
                    when Navigator::NORTH then Navigator::WEST
                    when Navigator::SOUTH then Navigator::EAST
                    when Navigator::WEST  then Navigator::SOUTH
                    when Navigator::EAST  then Navigator::NORTH
                    end
      else
        map.add_oxygen location if Navigator::FOUND_OXYGEN == response

        # Go right
        direction = case direction
                    when Navigator::NORTH then Navigator::EAST
                    when Navigator::SOUTH then Navigator::WEST
                    when Navigator::WEST  then Navigator::NORTH
                    when Navigator::EAST  then Navigator::SOUTH
                    end
      end
      break if (droid.position == [0, 0]) && (direction == Navigator::NORTH)
    end
    # map.visualize_with_droid droid.position

    # Save result
    IO.write('walls2', map.walls.to_s)
    IO.write('oxygen2', map.oxygen_location.to_s)
  end

  #=========================================================
  def test_diffusion
    map = MapOfShip.new

    # ----------------------------------------
    # Read map back from file
    # ----------------------------------------
    eval(IO.read('oxygen2')).each { |loc| map.add_oxygen loc }
    eval(IO.read('walls2')).each { |loc| map.add_wall loc }
    map.freeze_dimensions

    # ----------------------------------------
    # Colorize a few steps
    # ----------------------------------------
    minutes = 0
    seekers = map.oxygen_location
    map.color seekers, minutes

    while seekers.any? do
      minutes += 1
      seekers = map.paint_adjacent_to(seekers, minutes)
    end

    assert_equal 383, minutes
    puts "Diffuses in #{minutes - 1}"
    map.visualize_colorized

  end
end
