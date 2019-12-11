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

  def test_9_1
    program = [109,2000,109,19,204,-34,99]
    program[1985] = 1985
    output = []
    run_intcode([], output, *program)
    assert_equal 1985, output[0]
  end

# Hash of [x,y] for panels. New ones default to black/0
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
end
