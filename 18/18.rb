#
# Advent of Code 2019 day 18
#
require 'pp'
require 'test/unit'

#===========================================================
# Test driver18a
#===========================================================
class Examples18a < Test::Unit::TestCase

  # ========================================================
  def test_part1
    maze_lines = IO.readlines('input1.txt')

    map = Map.new
    map.add_image maze_lines
    map.draw


  end

end

#===========================================================
class Map

  def initialize
    @pixels = []
  end

  def add_image(maze_lines)
    maze_lines.each do |line|
      @pixels << line.strip.each_char.to_a
    end
  end

  def draw
    @pixels.each do |l|
      l.each { |c| print c }
      puts
    end
  end
end
