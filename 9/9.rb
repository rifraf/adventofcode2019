#
# Advent of Code 2019 day 9
#
require 'pp'
require 'test/unit'
require_relative '../intcode/intcode'
require_relative '../7/7'

#===========================================================
# Test driver9a
#===========================================================
class Examples9a < Test::Unit::TestCase
  def test_1
    program = [109,2000,109,19,204,-34,99]
    program[1985] = 1985
    output = []
    run_intcode([], output, *program)
    assert_equal 1985, output[0]
  end

  def test_2
    program = [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99].freeze
    output = []
    run_intcode([], output, *program)
    assert_equal output, program
  end

  def test_3
    program = [1102,34915192,34915192,7,4,7,99,0].freeze
    output = []
    run_intcode([], output, *program)
    assert_equal 1219070632396864, output[0]
  end

  def test_4
    program = [104,1125899906842624,99].freeze
    output = []
    run_intcode([], output, *program)
    assert_equal 1125899906842624, output[0]
  end

  def test_a
    program = IO.read('input1.txt').split(',').map(&:to_i)
    input = [1]
    output = []
    run_intcode(input, output, *program)
    assert_equal 3765554916, output[0] # <- correct
  end
end

#===========================================================
# Test driver9b
#===========================================================
class Examples9b < Test::Unit::TestCase
  def test_b
    program = IO.read('input1.txt').split(',').map(&:to_i)
    input = [2]
    output = []
    run_intcode(input, output, *program)
    assert_equal 76642, output[0] # <- correct
  end
end
