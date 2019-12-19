#
# Advent of Code 2019 day 15
#
require 'pp'
require 'test/unit'
require_relative '../intcode/intcode'
require_relative '../7/7'

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

    map.visualize_with_droid droid.position
  end

  #=========================================================
  def test_exploring_part1
    program = IO.read('input1.txt').split(',').map(&:to_i)
    map = MapOfShip.new
    navigator = Navigator.new(program)
    droid = Droid.new(navigator)

    # ----------------------------------------
    # Work out walls with random walk
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

    map.visualize_with_droid droid.position
  end
end

#===========================================================
class MapOfShip
  attr_reader :oxygen_location
  attr_reader :walls

  def initialize
    @oxygen_location = []
    @walls = []
  end

  def add_wall(loc)
    @walls << loc
  end

  def add_oxygen(loc)
    @oxygen_location << loc
  end

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
    (y_coords[0]..y_coords[-1]).each do |y|
      (x_coords[0]..x_coords[-1]).each do |x|
        print cells[[x, y]] || '.'
      end
      puts
    end
    puts
  end
end

#===========================================================
class DummyNavigator
  def initialize(responses)
    @responses = responses
  end

  def response_to_move(_move)
    @responses.shift
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

  def initialize(program)
    @input = Queue.new
    @output = Queue.new

    threads = []
    threads << Thread.new do
      puts 'Start intcode'
      run_intcode(@input, @output, *program)
      puts 'Stop intcode'
    end
  end

  def response_to_move(move)
    @input << move
    @output.pop
  end
end

#===========================================================
class Droid
  attr_reader :position

  def initialize(navigator)
    @position = [0, 0]
    @navigator = navigator
  end

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
