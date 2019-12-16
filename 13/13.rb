#
# Advent of Code 2019 day 13
#
require 'pp'
require 'test/unit'
require_relative '../intcode/intcode'

#===========================================================
# Test driver13a
#===========================================================
class Examples13a < Test::Unit::TestCase

  EMPTY = 0  # an empty tile. No game object appears in this tile.
  WALL = 1   # a wall tile. Walls are indestructible barriers.
  BLOCK = 2  # a block tile. Blocks can be broken by the ball.
  PADDLE = 3 # a horizontal paddle tile. The paddle is indestructible.
  BALL = 4   # a ball tile. The ball moves diagonally and bounces off objects.

  def test_1
    program = IO.read('input1.txt').split(',').map(&:to_i)
    input = []
    output = []
    run_intcode(input, output, *program)

    # Array of [x, y, tile]
    game = output.each_slice(3).to_a

    blocks = game.select { |location| location[2] == BLOCK }
    assert_equal 284, blocks.length # <- correct
  end
end
