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

  JOYSTICK_NEUTRAL = 0 # If the joystick is in the neutral position, provide 0.
  JOYSTICK_LEFT   = -1 # If the joystick is tilted to the left, provide -1.
  JOYSTICK_RIGHT   = 1 # If the joystick is tilted to the right, provide 1.

  # When three output instructions specify X=-1, Y=0, the third output instruction is the score
  MAGIC_X = -1
  MAGIC_Y =  0

  QUIT  = -99
  MIN_X = 0
  MAX_X = 42
  MIN_Y = 0
  MAX_Y = 20

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

  def test_2
    # First get the starting grid
    program = IO.read('input1.txt').split(',').map(&:to_i)
    input = []
    output1 = []
    run_intcode([], output1, *program)
    game = output1.each_slice(3).to_a # Array of [x, y, tile]
    assert_equal MIN_X, game.map { |location| location[0] }.min
    assert_equal MAX_X, game.map { |location| location[0] }.max
    assert_equal MIN_Y, game.map { |location| location[1] }.min
    assert_equal MAX_Y, game.map { |location| location[1] }.max

    # Now prime for the game
    program = IO.read('input1.txt').split(',').map(&:to_i)
    program[0] = 2 # Free play
    program_input = Queue.new
    program_output = Queue.new

    threads = []

    threads << Thread.new do
      run_intcode(program_input, program_output, *program.dup)
      program_output << QUIT
    end

    ball = game.find { |loc| loc[2] == BALL }[0..1]
    paddle = game.find { |loc| loc[2] == PADDLE }[0..1]
    score = 0

    threads << Thread.new do
      loop do
        x = program_output.pop
        break if x == QUIT

        y = program_output.pop
        tile = program_output.pop

        if (x == MAGIC_X) && (y == MAGIC_Y)
          score = tile
          print "Score #{tile}\r"
        elsif tile == BALL
          ball = [x, y]
          # puts "Ball is at #{ball}"
          program_input << JOYSTICK_LEFT if ball[0] < paddle[0]
          program_input << JOYSTICK_RIGHT if ball[0] > paddle[0]
          program_input << JOYSTICK_NEUTRAL if ball[0] == paddle[0]
        elsif tile == PADDLE
          paddle = [x, y]
          # puts "Paddle is at #{paddle}"
        end
      end
    end

    threads.each { |thr| thr.join }

    assert_equal 13_581, score # <- correct
  end

end
