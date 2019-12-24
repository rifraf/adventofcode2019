#
# Advent of Code 2019 day 17
#
require 'pp'
require 'test/unit'
require_relative '../intcode/intcode'

#===========================================================
# Test driver17a
#===========================================================
class Examples17a < Test::Unit::TestCase

  def test_part1
    program = IO.read('input1.txt').split(',').map(&:to_i)

    output = []
    run_intcode([], output, *program)

    output.each { |c| print c.chr }
  end
end

