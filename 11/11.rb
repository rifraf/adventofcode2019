#
# Advent of Code 2019 day 11
#
require 'pp'
require 'test/unit'
require_relative '../intcode/intcode'

#===========================================================
# Test driver11a
#===========================================================
class Examples11a < Test::Unit::TestCase
  def test_9_1_still_works
    program = [109,2000,109,19,204,-34,99]
    program[1985] = 1985
    output = []
    run_intcode([], output, *program)
    assert_equal 1985, output[0]
  end

  def test_painter_no_op
    ship_surface = Panels.new
    assert_equal 0, ship_surface.white_panels.length
    assert_equal 0, ship_surface.black_panels.length
    assert_equal 0, ship_surface.painted_panels.length
    assert_equal Panels::BLACK, ship_surface.colour_of_current_panel
  end

  def test_painter_left_right
    ship_surface = Panels.new

    ship_surface.paint Panels::WHITE
    ship_surface.move Panels::LEFT
    assert_equal 1, ship_surface.white_panels.length
    assert_equal [[0, 0]], ship_surface.white_panels
    assert_equal 0, ship_surface.black_panels.length
    assert_equal 1, ship_surface.painted_panels.length
    assert_equal Panels::BLACK, ship_surface.colour_of_current_panel

    ship_surface.paint Panels::WHITE
    ship_surface.move Panels::LEFT
    assert_equal 2, ship_surface.white_panels.length
    assert_equal [[0, 0], [-1, 0]], ship_surface.white_panels
    assert_equal 0, ship_surface.black_panels.length
    assert_equal 2, ship_surface.painted_panels.length
    assert_equal Panels::BLACK, ship_surface.colour_of_current_panel
  end

  def test_painter_zigzag
    ship_surface = Panels.new

    ship_surface.paint Panels::WHITE
    ship_surface.move Panels::LEFT
    assert_equal [[0, 0]], ship_surface.white_panels
    assert_equal [], ship_surface.black_panels
    assert_equal 1, ship_surface.painted_panels.length
    assert_equal Panels::BLACK, ship_surface.colour_of_current_panel

    ship_surface.paint Panels::BLACK
    ship_surface.move Panels::RIGHT
    assert_equal [[0, 0]], ship_surface.white_panels
    assert_equal [[-1, 0]], ship_surface.black_panels
    assert_equal 2, ship_surface.painted_panels.length
    assert_equal Panels::BLACK, ship_surface.colour_of_current_panel

    ship_surface.paint Panels::WHITE
    ship_surface.move Panels::LEFT
    assert_equal [[0, 0], [-1, 1]], ship_surface.white_panels
    assert_equal [[-1, 0]], ship_surface.black_panels
    assert_equal 3, ship_surface.painted_panels.length
    assert_equal Panels::BLACK, ship_surface.colour_of_current_panel

    ship_surface.paint Panels::BLACK
    ship_surface.move Panels::RIGHT
    assert_equal [[0, 0], [-1, 1]], ship_surface.white_panels
    assert_equal [[-1, 0], [-2, 1]], ship_surface.black_panels
    assert_equal 4, ship_surface.painted_panels.length
    assert_equal Panels::BLACK, ship_surface.colour_of_current_panel
  end

  def test_part1
    # Thread 1:
    #  Start intcode with [0]
    #  It outputs [new_colour, direction]
    #  It waits for input and repeats till end
    #  Post 'end of program' as output
    # Thread 2:
    #  Waits for [new_colour, direction] or 'end of program'
    #  Updates panel (paint colour then move left/right one)
    #  Post colour at new position to thread1
    #
    ship_surface = Panels.new

    program = IO.read('input1.txt').split(',').map(&:to_i)
    program_input = Queue.new << 0
    program_output = Queue.new

    threads = []
    threads << Thread.new do
      run_intcode(program_input, program_output, *program)
      program_output << Panels::QUIT
    end
    threads << Thread.new do
      loop do
        colour = program_output.pop
        break if colour == Panels::QUIT

        ship_surface.paint colour

        direction = program_output.pop
        ship_surface.move direction

        program_input.push ship_surface.colour_of_current_panel
      end
    end

    threads.each(&:join)

    puts "#{ship_surface.painted_panels.length} panels were painted"
    assert_equal 2016, ship_surface.painted_panels.length # <- correct
  end
end

#===========================================================
class Panels
  LEFT = 0
  RIGHT = 1
  BLACK = 0
  WHITE = 1
  QUIT = -1

  def initialize
    @x = 0
    @y = 0
    @forward = [0, 1]
    # Index by [x, y]
    # Records only painted panels: 0=black, 1=white
    @painted_panels = {}
    # puts
  end

  def white_panels
    @painted_panels.select { |where, colour| colour == WHITE }.keys
  end

  def black_panels
    @painted_panels.select { |where, colour| colour == BLACK }.keys
  end

  def painted_panels
    @painted_panels.keys
  end

  def paint(colour)
    # puts "Paint [#{@x}, #{@y}] #{colour}"
    @painted_panels[[@x, @y]] = colour
  end

  def colour_of_current_panel
    # Unpainted panels report as black
    @painted_panels[[@x, @y]] == WHITE ? WHITE : BLACK
  end

  def move(direction)
    @forward = case direction
    when LEFT
      case @forward
      when [0, 1]  then [-1, 0]  # ^ <
      when [-1, 0] then [0, -1]  # < v
      when [0, -1] then [1, 0]   # v >
      when [1, 0]  then [0, 1]   # > ^
      end
    when RIGHT
      case @forward
      when [0, 1]  then [1, 0]   # ^ >
      when [1, 0]  then [0, -1]  # > v
      when [0, -1] then [-1, 0]  # v <
      when [-1, 0] then [0, 1]   # < ^
      end
    end
    @x += @forward[0]
    @y += @forward[1]
    # puts "Move #{direction} to [#{@x}, #{@y}]"
  end
end
