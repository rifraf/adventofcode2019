#
# Advent of Code 2019 day 19
#
require 'pp'
require 'test/unit'
require_relative '../intcode/intcode'

#===========================================================
# Test driver19a
#===========================================================
class Examples19a < Test::Unit::TestCase
  X_RANGE = 50
  Y_RANGE = 50

  def test_1
    program = IO.read('input1.txt').split(',').map(&:to_i)

    input = Queue.new
    output = Queue.new

    num = 0
    Y_RANGE.times do |y|
      puts
      X_RANGE.times do |x|
        input << x << y
        run_intcode(input, output, *program.dup)
        result = output.pop
        print result
        num += result
      end
    end
    puts

    assert_equal 121, num # <- correct
  end
end
