#
# Advent of Code 2018 day 12
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
# Test driver
#===========================================================
class Examples < Test::Unit::TestCase
  def test_example1
    assert_equal 2, fuel_for_mass(12)
  end

  def test_example2
    assert_equal 2, fuel_for_mass(14)
  end

  def test_example3
    assert_equal 654, fuel_for_mass(1969)
  end

  def test_example4
    assert_equal 33_583, fuel_for_mass(100_756)
  end
end

#===========================================================
def fuel_for_mass(mass)
  (mass / 3).floor - 2
end

lines = 0
total_fuel = 0
IO.readlines('input1.txt').each do |mass|
  lines += 1
  total_fuel += fuel_for_mass(mass.to_i)
end

puts "#{lines} modules needs #{total_fuel} fuel."
