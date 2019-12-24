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

  # ========================================================
  def test_example
    example = "..#..........
..#..........
#######...###
#.#...#...#.#
#############
..#...#...#..
..#####...^.."

    map = Map.new
    map.add_image example.chars.map(&:ord)
    map.draw

    assert_equal [[2, 2], [2, 4], [6, 4], [10, 4]], map.intersections
    assert_equal 76, map.intersections.map { |loc| loc[0] * loc[1] }.reduce(&:+)
  end

  # ========================================================
  def test_part1
    program = IO.read('input1.txt').split(',').map(&:to_i)

    output = []
    run_intcode([], output, *program)

    map = Map.new
    map.add_image output
    map.draw

    intersections = map.intersections
    assert_equal [[14, 8], [16, 12], [24, 16], [26, 26], [16, 28], [22, 28], [12, 34], [14, 34], [2, 48], [10, 52], [12, 56]], intersections
    assert_equal 4600, intersections.map { |loc| loc[0] * loc[1] }.reduce(&:+)  # <- correct
  end
end

#===========================================================
class Map

  def initialize
    @scaffold_points = []
    @x_max = 0
    @y_max = 0
  end

  def intersections
    @scaffold_points.select do |loc|
      x = loc[0]
      y = loc[1]
      @scaffold_points.include?([x - 1, y]) &&
        @scaffold_points.include?([x + 1, y]) &&
        @scaffold_points.include?([x, y - 1]) &&
        @scaffold_points.include?([x, y + 1])
    end
  end

  def add_image(image)
    x = 0
    y = 0
    image.each do |pix|
      case pix
      when 10 # \n
        x = 0
        y += 1
      when 46 # '.'
        x += 1
      when 35 # '#'
        @scaffold_points << [x, y]
        x += 1
      when 'X'.ord  # Fallen off
        x += 1
      when '^'.ord, 'v'.ord, '<'.ord, '>'.ord # Droid
        @scaffold_points << [x, y]
        @droid_location = [x, y]
        @droid_direction = pix
        x += 1
      end
      @x_max = [x, @x_max].max
      @y_max = [y, @y_max].max
    end
  end

  def draw
    puts
    (0..@y_max).each do |y|
      (0..@x_max).each do |x|
        if @scaffold_points.include?([x, y])
          print '#'
        else
          print '.'
        end
      end
      puts
    end
    puts
  end
end
