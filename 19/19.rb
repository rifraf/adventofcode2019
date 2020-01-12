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

  #=========================================================
  def test_trivial_implementation
    program = IO.read('input1.txt').split(',').map(&:to_i)

    input = Queue.new
    output = Queue.new

    num = 0
    Y_RANGE.times do |y|
      # puts
      X_RANGE.times do |x|
        input << x << y
        run_intcode(input, output, *program.dup)
        result = output.pop
        # print result
        num += result
      end
    end
    puts

    assert_equal 121, num # <- correct
  end

  #=========================================================
  def test_sleeker_implementation
    program = IO.read('input1.txt').split(',').map(&:to_i)

    input = Queue.new
    output = Queue.new

    num = 0
    x_min = 0
    x_max = X_RANGE - 1
    Y_RANGE.times do |y|
      puts
      print ' ' * x_min
      last_one = nil
      first_one = nil
      (x_min..x_max).each do |x|
        input << x << y
        run_intcode(input, output, *program.dup)
        result = output.pop

        # Off rhs?
        break if result.zero? && !first_one.nil?

        # Found lhs?
        if result == 1
          x_min = x if first_one.nil?
          first_one ||= x
          last_one = x
        end

        print result
        num += result
      end
      break if first_one.nil? # None found
    end
    puts

    assert_equal 121, num # <- correct
  end

  #=========================================================
  def test_boundary_box
    program = IO.read('input1.txt').split(',').map(&:to_i)

    input = Queue.new
    output = Queue.new
    boundary = []
    xy_for_box2 = []
    xy_for_box3 = []
    xy_for_box4 = []

    num = 0
    x_min = 0
    x_max = X_RANGE - 1
    Y_RANGE.times do |y|
      puts
      print ' ' * x_min
      last_one = nil
      first_one = nil
      (x_min..x_max).each do |x|
        input << x << y
        run_intcode(input, output, *program.dup)
        result = output.pop

        # Off rhs?
        break if result.zero? && !first_one.nil?

        # Found lhs?
        if result == 1
          x_min = x if first_one.nil?
          first_one ||= x
          last_one = x
        end

        print result
        num += result
      end
      break if first_one.nil? # None found

      boundary << (first_one..last_one)
      xy_for_box2 << box_in_boundary(boundary, 2)
      xy_for_box3 << box_in_boundary(boundary, 3)
      xy_for_box4 << box_in_boundary(boundary, 4)
    end
    puts

    # p xy_for_box2.compact
    # p xy_for_box3.compact
    # p xy_for_box4.compact

    assert_equal [21, 11], xy_for_box2.compact.first
    assert_equal [33, 17], xy_for_box3.compact.first
    assert_equal [], xy_for_box4.compact
    assert_equal 121, num # <- correct
  end
end

#===========================================================
# Add intersection method to range
#===========================================================
class Range
  def intersection(other)
    [self.min, other.min].max..[self.max, other.max].min
  end
end

#===========================================================
def box_in_boundary(boundary, box_size)
  most_recent = boundary[-1]
  # p most_recent
  # p most_recent.size
  return nil unless most_recent.size >= box_size
  return nil unless boundary.size >= box_size

  intersection = boundary[-box_size].intersection(most_recent)
  return [intersection.first, boundary.size - box_size] if intersection.size >= box_size

  nil
end

#===========================================================
# Test driver19b
#===========================================================
class Examples19b < Test::Unit::TestCase
  #=========================================================
  def test_part2
    program = IO.read('input1.txt').split(',').map(&:to_i)

    input = Queue.new
    output = Queue.new
    boundary = []

    x_min = 0
    x_max = 2000
    previous_right_edge = -1
    encoded_xy = nil
    10000.times do |y|
      last_one = nil
      first_one = nil
      (x_min..x_max).each do |x|
        next if first_one && (x < previous_right_edge)
        input << x << y
        run_intcode(input, output, *program.dup)
        result = output.pop

        # Off rhs?
        break if result.zero? && !first_one.nil?

        # Found lhs?
        next unless result == 1

        x_min = x if first_one.nil?
        first_one ||= x
        last_one = x
      end
      break if first_one.nil? # None found

      previous_right_edge = last_one
      boundary << (first_one..last_one)
      if (xy_for_box = box_in_boundary(boundary, 100))
        puts "Box fits at #{xy_for_box}"
        encoded_xy = xy_for_box[0] * 10_000 + xy_for_box[1]
        puts encoded_xy
        break
      end
    end
    assert_equal 15090773, encoded_xy
    # p boundary
  end
end
