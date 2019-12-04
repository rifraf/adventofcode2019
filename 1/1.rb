#
# Advent of Code 2019 day 1
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

#===========================================================
# Part 1
#===========================================================
lines = 0
total_fuel = 0
IO.readlines('input1.txt').each do |mass|
  lines += 1
  total_fuel += fuel_for_mass(mass.to_i)
end

puts "#{lines} modules needs #{total_fuel} fuel."  # <- 100 modules needs 3256794 fuel.

#
# Fuel itself requires fuel just like a module - take its mass, divide by three, round down, and subtract 2.
# However, that fuel also requires fuel, and that fuel requires fuel, and so on. Any mass that would require
# negative fuel should instead be treated as if it requires zero fuel; the remaining mass, if any, is instead
# handled by wishing really hard, which has no mass and is outside the scope of this calculation.
#
# So, for each module mass, calculate its fuel and add it to the total.
# Then, treat the fuel amount you just calculated as the input mass and repeat the process,
# continuing until a fuel requirement is zero or negative. For example:
#
# A module of mass 14 requires 2 fuel. This fuel requires no further fuel (2 divided by 3 and rounded down is 0, which would call for a negative fuel), so the total fuel required is still just 2.
# At first, a module of mass 1969 requires 654 fuel. Then, this fuel requires 216 more fuel (654 / 3 - 2). 216 then requires 70 more fuel, which requires 21 fuel, which requires 5 fuel, which requires no further fuel. So, the total fuel required for a module of mass 1969 is 654 + 216 + 70 + 21 + 5 = 966.
# The fuel required by a module of mass 100756 and its fuel is: 33583 + 11192 + 3728 + 1240 + 411 + 135 + 43 + 12 + 2 = 50346.
#
# What is the sum of the fuel requirements for all of the modules on your spacecraft when also taking into account the mass of the added fuel? (Calculate the fuel requirements for each module separately, then add them all up at the end.)

#===========================================================
# Test driver2
#===========================================================
class Examples2 < Test::Unit::TestCase
  def test_example1
    assert_equal 2, fuel_for_mass(14)
    assert_equal 2, fuel_for_fuel(2)
  end

  def test_example2
    assert_equal 654, fuel_for_mass(1969)
    assert_equal 966, fuel_for_fuel(654)
  end

  def test_example3
    assert_equal 33583, fuel_for_mass(100756)
    assert_equal 50346, fuel_for_fuel(33583)
  end
end

#===========================================================
def fuel_for_fuel(fuel_mass)
  total = fuel_mass
  additional = fuel_for_mass(fuel_mass)
  # p [fuel_mass, additional]
  while (additional > 0)
    total += additional
    # p [fuel_for_mass(additional), additional]
    additional = fuel_for_mass(additional)
  end
  total
end

#===========================================================
# Part 2
#===========================================================
lines = 0
total_fuel = 0
IO.readlines('input1.txt').each do |mass|
  lines += 1
  module_mass = mass.to_i
  ffm = fuel_for_mass(module_mass)
  fff = fuel_for_fuel(ffm)
  total_fuel += fff
end

puts "#{lines} modules needs #{total_fuel} fuel."  # <- 100 modules needs 4882337 fuel.
