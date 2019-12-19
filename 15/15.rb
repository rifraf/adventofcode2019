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

  def test_going_nowhere
    map = MapOfShip.new
    navigator = DummyNavigator.new([Navigator::WALL, Navigator::WALL, Navigator::WALL, Navigator::WALL])
    droid = Droid.new(navigator)

    assert_equal MapOfShip::UNKNOWN_LOCATION, map.oxygen_location
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

    # Head bang 4
    response, location = droid.move(Navigator::WEST)
    assert_equal Navigator::WALL, response
    assert_equal [0, 0], droid.position

    map.add_wall location
    assert_equal [[0, 1], [0, -1], [1, 0], [-1, 0]], map.walls
  end
end

#===========================================================
class MapOfShip

  UNKNOWN_LOCATION = '?'

  attr_reader :oxygen_location
  attr_reader :walls
  # attr_reader :droid_location

  def initialize
    # @droid_location = [0, 0]
    @oxygen_location = UNKNOWN_LOCATION
    @walls = []
  end

  def add_wall(loc)
    @walls << loc
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

#===========================================================
class DummyNavigator

  def initialize(responses)
    @responses = responses
  end

  def response_to_move(_move)
    @responses.shift
  end
end
