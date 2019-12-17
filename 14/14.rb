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
    # pp cookbook

    assert_equal 1, cookbook.element('A').max_reactions
    assert_equal 1, cookbook.element('B').max_reactions
    assert_equal 2, cookbook.element('C').max_reactions
    assert_equal 3, cookbook.element('D').max_reactions
    assert_equal 4, cookbook.element('E').max_reactions
    assert_equal 5, cookbook.element('FUEL').max_reactions

    pp cookbook.element('FUEL').calculate_ore_quantity
    # assert_equal 10, cookbook.element('A').input_quantity(1, 'ORE')
    # assert_equal 10, cookbook.element('A').input_quantity(9, 'ORE')
    # assert_equal 10, cookbook.element('A').input_quantity(10, 'ORE')
    # assert_equal 20, cookbook.element('A').input_quantity(11, 'ORE')

    # assert_equal 1, cookbook.element('B').input_quantity('ORE')
    # assert_equal 11, cookbook.element('C').input_quantity('ORE')
  end

end

#===========================================================
class CookBook
  def initialize
    @elements = {
      'ORE' => Element.new('ORE', 1)
    }
  end

  def element(name)
    @elements[name]
  end

  def add_recipes(recipes)
    recipes.each { |r| add_recipe r }
    @elements.each { |_k, e| e.resolve_precursor @elements }
  end

  def add_recipe(recipe)
    source, dest = recipe.split("=>")
    return unless dest =~ /(\d+)\s+(\S+)/

    min_qty = $1.to_i
    name = $2
    @elements[name] = Element.new(name, min_qty)
    @elements[name].built_from(source)
  end
end

#===========================================================
class Element

  attr_reader :building_blocks

  def initialize(name, min_qty)
    @name = name
    @min_qty = min_qty
    @built_from = []
    @building_blocks = {}
  end

  def built_from(source)
    @built_from = source.split(',').map do |src|
      src =~ /(\d+)\s+(\S+)/
      [$1.to_i, $2]
    end
  end

  def resolve_precursor(element_map)
    @built_from.each do |qty, name|
      @building_blocks[element_map[name]] = qty
    end
  end

  def max_reactions
    return 0 if @building_blocks.empty?
    @max_reactions ||= @building_blocks.keys.map { |el| 1 + el.max_reactions }.max
  end

  # def input_quantity(required, base_element)
  #   return min_qty if @name == base_element
  #   total = 0
  #   # required =
  #   # @built_from.each do |qty, el|
  #   #   total += required * @cookbook.element(el).input_quantity(qty, base_element)
  #   # end
  #   total
  # end

  def calculate_ore_quantity
    new_blocks = {}
    @building_blocks.each do |el, min_qty|
      if el.max_reactions == 1
        new_blocks[el] = qty
      else
        el.building_blocks.each do |next_el, next_qty|
          new_blocks[next_el] = next_qty
        end
      end
    end
  end

end
