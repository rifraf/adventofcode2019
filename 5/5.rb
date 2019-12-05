#
# Advent of Code 2019 day 5
#
require 'pp'
require 'test/unit'

#===========================================================
# Test driver2a
#===========================================================
class Examples2a < Test::Unit::TestCase
  def test_example1
    assert_equal [3500,9,10,70,2,3,11,0,99,30,40,50], run_intcode([], [], 1,9,10,3,2,3,11,0,99,30,40,50)
  end

  def test_example2
    assert_equal [2,3,0,6,99], run_intcode([], [], 2,3,0,3,99)
  end

  def test_example3
    assert_equal [2,4,4,5,99,9801], run_intcode([], [], 2,4,4,5,99,0)
  end

  def test_example4
    assert_equal [30,1,1,4,2,5,6,0,99], run_intcode([], [], 1,1,1,4,99,5,6,0,99)
  end

end

#===========================================================
def run_intcode(input, output, *program)
  index = 0
  while (program[index] % 100)!= 99
    opcode = program[index] % 100
    case opcode
    when 1
      sum = program[program[index + 1]] + program[program[index + 2]]
      program[program[index + 3]] = sum
      index += 4
    when 2
      prod = program[program[index + 1]] * program[program[index + 2]]
      program[program [index + 3]] = prod
      index += 4
    when 3
      value = input.shift
      program[program [index + 1]] = value
      index += 2
    when 4
      value = program[program [index + 1]]
      output << value
      index += 2
    else
      puts
      puts "Invalid OP #{program[index]} at #{index}"
      exit(1)
    end
  end
  program
end

#===========================================================
class Examples2b < Test::Unit::TestCase
  def test_input
    # original = [1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,9,1,19,1,19,5,23,1,9,23,27,2,27,6,31,1,5,31,35,2,9,35,39,2,6,39,43,2,43,13,47,2,13,47,51,1,10,51,55,1,9,55,59,1,6,59,63,2,63,9,67,1,67,6,71,1,71,13,75,1,6,75,79,1,9,79,83,2,9,83,87,1,87,6,91,1,91,13,95,2,6,95,99,1,10,99,103,2,103,9,107,1,6,107,111,1,10,111,115,2,6,115,119,1,5,119,123,1,123,13,127,1,127,5,131,1,6,131,135,2,135,13,139,1,139,2,143,1,143,10,0,99,2,0,14,0]
    part1    = [1,12,2,3,1,1,2,3,1,3,4,3,1,5,0,3,2,9,1,19,1,19,5,23,1,9,23,27,2,27,6,31,1,5,31,35,2,9,35,39,2,6,39,43,2,43,13,47,2,13,47,51,1,10,51,55,1,9,55,59,1,6,59,63,2,63,9,67,1,67,6,71,1,71,13,75,1,6,75,79,1,9,79,83,2,9,83,87,1,87,6,91,1,91,13,95,2,6,95,99,1,10,99,103,2,103,9,107,1,6,107,111,1,10,111,115,2,6,115,119,1,5,119,123,1,123,13,127,1,127,5,131,1,6,131,135,2,135,13,139,1,139,2,143,1,143,10,0,99,2,0,14,0]
    assert_equal 6568671, run_intcode([], [], *part1)[0]
  end
end

#===========================================================
class Examples2c < Test::Unit::TestCase
  def test_input
    100.times do |a|
      100.times do |b|
        program = [1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,9,1,19,1,19,5,23,1,9,23,27,2,27,6,31,1,5,31,35,2,9,35,39,2,6,39,43,2,43,13,47,2,13,47,51,1,10,51,55,1,9,55,59,1,6,59,63,2,63,9,67,1,67,6,71,1,71,13,75,1,6,75,79,1,9,79,83,2,9,83,87,1,87,6,91,1,91,13,95,2,6,95,99,1,10,99,103,2,103,9,107,1,6,107,111,1,10,111,115,2,6,115,119,1,5,119,123,1,123,13,127,1,127,5,131,1,6,131,135,2,135,13,139,1,139,2,143,1,143,10,0,99,2,0,14,0]
        program[1] = a
        program[2] = b
        new_program = run_intcode([], [], *program) # rescue nil
        if new_program[0] == 19690720
          assert_equal 3951, a * 100 + b
          break
        end
      end
    end
  end
end

#===========================================================
# Test driver5a
#===========================================================
class Examples5a < Test::Unit::TestCase

  def test_input
    prog = [3, 0, 4, 0, 99]
    input  = [1]
    output = []
    run_intcode(input, output, *prog)
    assert_equal [1], output
  end

  def test_param1
    prog = [2, 4, 4, 0, 99]
    modified = run_intcode([], [], *prog)
    assert_equal [9801, 4, 4, 0, 99], modified

    prog = [1002, 4, 4, 0, 99]
    modified = run_intcode([], [], *prog)
    assert_not_equal [9801, 4, 4, 0, 99], modified
  end
end
