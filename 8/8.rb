#
# Advent of Code 2019 day 8
#
require 'pp'
require 'test/unit'
require_relative '../intcode/intcode'

#===========================================================
# Test driver8a
#===========================================================
class Examples8a < Test::Unit::TestCase
  def test_1
    image = '123456789012'
    assert_equal [[1,2,3,4,5,6], [7,8,9,0,1,2]], layers_in_image(image, 3, 2)
  end

  def test_part1
    image = IO.read('input1.txt').strip
    layers = layers_in_image(image, 25, 6)
    by_zero_count = {}
    layers.each do |layer|
      zeros = layer.count(0)
      by_zero_count[zeros] ||= []
      by_zero_count[zeros] << layer
    end
    key = by_zero_count.keys.min
    puts "Lowest number of zeros is #{key}"
    layer_of_interest = by_zero_count[key][0]
    ones = layer_of_interest.count(1)
    twos = layer_of_interest.count(2)

    puts "Result #{ones * twos}"
    assert_equal 1716, ones * twos # <- correct
  end
end

def layers_in_image(image, width, height)
  pixels = image.chars.map(&:to_i)
  pixels_per_layer = width * height
  pixels.each_slice(pixels_per_layer).to_a
end

#===========================================================
# Test driver8b
#===========================================================
class Examples8b < Test::Unit::TestCase
  def test_1
    image = '0222112222120000'
    assert_equal [[0,2,2,2], [1,1,2,2], [2,2,1,2], [0,0,0,0]], layers_in_image(image, 2, 2)

    full_image = combine_layers(image, 2, 2)
    assert_equal [0, 1, 1, 0], full_image
  end

  def test_part1
    image = IO.read('input1.txt').strip
    full_image = combine_layers(image, 25, 6)
    display_image(full_image, 25, 6) # <- KFABY in ASCII art
  end
end

#===========================================================
def combine_layers(image, width, height)
  image_size = width * height
  full_image = [2] * image_size
  layers_in_image(image, width, height).each do |layer|
    image_size.times do |i|
      full_image[i] = layer[i] if full_image[i] == 2
    end
  end
  full_image
end

#===========================================================
def display_image(image, width, _height)
  puts
  image.each_slice(width).each do |row|
    puts row.map { |v| v == 1 ? '*' : ' ' }.join
  end
end
