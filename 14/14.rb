#
# Advent of Code 2019 day 14
#
require 'pp'
require 'test/unit'

#===========================================================
# Test driver14
#===========================================================
class Examples14 < Test::Unit::TestCase
  def test_example1
    reactions = [
      '10 ORE => 10 A',
      '1 ORE => 1 B',
      '7 A, 1 B => 1 C',
      '7 A, 1 C => 1 D',
      '7 A, 1 D => 1 E',
      '7 A, 1 E => 1 FUEL'
    ]

    cookbook = CookBook.new
    cookbook.add_recipes reactions
    pp cookbook

    assert_equal 10, cookbook.element('A').input_quantity(1, 'ORE')
    assert_equal 10, cookbook.element('A').input_quantity(9, 'ORE')
    assert_equal 10, cookbook.element('A').input_quantity(10, 'ORE')
    assert_equal 20, cookbook.element('A').input_quantity(11, 'ORE')

    # assert_equal 1, cookbook.element('B').input_quantity('ORE')
    # assert_equal 11, cookbook.element('C').input_quantity('ORE')
  end

end

#===========================================================
class CookBook
  def initialize
    @elements = {
      'ORE' => Element.new('ORE', 1, self)
    }
  end

  def element(name)
    @elements[name]
  end

  def add_recipes(recipes)
    recipes.each { |r| add_recipe r }
  end

  def add_recipe(recipe)
    source, dest = recipe.split("=>")
    if dest =~ /(\d+)\s+(\S+)/
      name = $2
      min_qty = $1.to_i
      @elements[name] = Element.new(name, min_qty, self)
      @elements[name].built_from(source)
    end
  end
end

#===========================================================
class Element
  def initialize(name, min_qty, cookbook)
    @name = name
    @min_qty = min_qty
    @cookbook = cookbook
    @built_from = []
  end

  def built_from(source)
    @built_from = source.split(',').map do |src|
      src =~ /(\d+)\s+(\S+)/
      [@min_qty, $1.to_i, $2]
    end
  end

  def input_quantity(required, base_element)
    return min_qty if @name == base_element
    total = 0
    # required =
    # @built_from.each do |qty, el|
    #   total += required * @cookbook.element(el).input_quantity(qty, base_element)
    # end
    total
  end

end
