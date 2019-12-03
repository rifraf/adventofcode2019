#
# Advent of Code 2018 day 2
#
require 'pp'
require 'test/unit'
#
# Fuel required to launch a given module is based on its mass. Specifically, to find the fuel required for a module, take its mass, divide by three, round down, and subtract 2.
#
# For example:
# For a mass of 12, divide by 3 and round down to get 4, then subtract 2 to get 2.
# For a mass of 14, dividing by 3 and rounding down still yields 4, so the fuel required is also 2.
# For a mass of 1969, the fuel required is 654.
# For a mass of 100756, the fuel required is 33583.
# The Fuel Counter-Upper needs to know the total fuel requirement. To find it, individually calculate the fuel needed for the mass of each module (your puzzle input), then add together all the fuel values.
# What is the sum of the fuel requirements for all of the modules on your spacecraft?
#

#===========================================================
# Test driver1
#===========================================================
class Examples1 < Test::Unit::TestCase
  def test_example1
    assert_equal [3500,9,10,70,2,3,11,0,99,30,40,50], run_intcode(1,9,10,3,2,3,11,0,99,30,40,50)
  end

  def test_example2
    assert_equal [2,3,0,6,99], run_intcode(2,3,0,3,99)
  end

  def test_example3
    assert_equal [2,4,4,5,99,9801], run_intcode(2,4,4,5,99,0)
  end

  def test_example4
    assert_equal [30,1,1,4,2,5,6,0,99], run_intcode(1,1,1,4,99,5,6,0,99)
  end

end

#===========================================================
def run_intcode(*program)
  index = 0
  while program[index] != 99
    case program[index]
    when 1
      sum = program[program[index + 1]] + program[program[index + 2]]
      program[program[index + 3]] = sum
      index += 4
    when 2
      prod = program[program[index + 1]] * program[program[index + 2]]
      program[program [index + 3]] = prod
      index += 4
    else
      puts
      puts "Invalid OP #{program[index]} at #{index}"
      exit(1)
    end
  end
  program
end

#===========================================================
original = [1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,9,1,19,1,19,5,23,1,9,23,27,2,27,6,31,1,5,31,35,2,9,35,39,2,6,39,43,2,43,13,47,2,13,47,51,1,10,51,55,1,9,55,59,1,6,59,63,2,63,9,67,1,67,6,71,1,71,13,75,1,6,75,79,1,9,79,83,2,9,83,87,1,87,6,91,1,91,13,95,2,6,95,99,1,10,99,103,2,103,9,107,1,6,107,111,1,10,111,115,2,6,115,119,1,5,119,123,1,123,13,127,1,127,5,131,1,6,131,135,2,135,13,139,1,139,2,143,1,143,10,0,99,2,0,14,0]
part1    = [1,12,2,3,1,1,2,3,1,3,4,3,1,5,0,3,2,9,1,19,1,19,5,23,1,9,23,27,2,27,6,31,1,5,31,35,2,9,35,39,2,6,39,43,2,43,13,47,2,13,47,51,1,10,51,55,1,9,55,59,1,6,59,63,2,63,9,67,1,67,6,71,1,71,13,75,1,6,75,79,1,9,79,83,2,9,83,87,1,87,6,91,1,91,13,95,2,6,95,99,1,10,99,103,2,103,9,107,1,6,107,111,1,10,111,115,2,6,115,119,1,5,119,123,1,123,13,127,1,127,5,131,1,6,131,135,2,135,13,139,1,139,2,143,1,143,10,0,99,2,0,14,0]
p run_intcode(*part1) # <- 6568671 OK
puts

#===========================================================
100.times do |a|
  100.times do |b|
    program = [1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,9,1,19,1,19,5,23,1,9,23,27,2,27,6,31,1,5,31,35,2,9,35,39,2,6,39,43,2,43,13,47,2,13,47,51,1,10,51,55,1,9,55,59,1,6,59,63,2,63,9,67,1,67,6,71,1,71,13,75,1,6,75,79,1,9,79,83,2,9,83,87,1,87,6,91,1,91,13,95,2,6,95,99,1,10,99,103,2,103,9,107,1,6,107,111,1,10,111,115,2,6,115,119,1,5,119,123,1,123,13,127,1,127,5,131,1,6,131,135,2,135,13,139,1,139,2,143,1,143,10,0,99,2,0,14,0]
    program[1] = a
    program[2] = b
    new_program = run_intcode(*program) # rescue nil
    # p new_program[0..4]
    if new_program[0] == 19690720
      puts "Matched with #{a} #{b} -> #{a * 100 + b}" # <- 3951
      p program
      exit(0)
    end
  end
end
