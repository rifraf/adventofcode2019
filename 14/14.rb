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
      '7 A, 1 E => 1 FUEL',
      '7 A, 1 E => 3 BOBS'
    ]

    cookbook = CookBook.new
    cookbook.add_recipes reactions

    # Check we can work out which need most steps
    assert_equal 1, cookbook.element('A').max_reactions
    assert_equal 1, cookbook.element('B').max_reactions
    assert_equal 2, cookbook.element('C').max_reactions
    assert_equal 3, cookbook.element('D').max_reactions
    assert_equal 4, cookbook.element('E').max_reactions
    assert_equal 5, cookbook.element('FUEL').max_reactions

    # Check we can get the next step formula for an element
    assert_equal [['E', 1], ['A', 7]], cookbook.formula_for(1, 'FUEL')
    assert_equal [['E', 2], ['A', 14]], cookbook.formula_for(2, 'FUEL')

    assert_equal [['E', 1], ['A', 7]], cookbook.formula_for(1, 'BOBS')
    assert_equal [['E', 1], ['A', 7]], cookbook.formula_for(3, 'BOBS')
    assert_equal [['E', 2], ['A', 14]], cookbook.formula_for(4, 'BOBS')
    assert_equal [['E', 2], ['A', 14]], cookbook.formula_for(6, 'BOBS')
    assert_equal [['E', 3], ['A', 21]], cookbook.formula_for(7, 'BOBS')

    assert_equal [['ORE', 10]], cookbook.formula_for(1, 'A')
    assert_equal [['ORE', 10]], cookbook.formula_for(9, 'A')
    assert_equal [['ORE', 10]], cookbook.formula_for(10, 'A')
    assert_equal [['ORE', 20]], cookbook.formula_for(11, 'A')

    # Now reduce the formulae
    assert_equal [['D', 1], ['A', 14]], cookbook.reduce([['E', 1], ['A', 7]])
    assert_equal [['C', 1], ['A', 21]], cookbook.reduce([['D', 1], ['A', 14]])
    assert_equal [['A', 28], ['B', 1]], cookbook.reduce([['C', 1], ['A', 21]])
    assert_equal [['ORE', 31]], cookbook.reduce([['A', 28], ['B', 1]])

    # Wrap in a helper
    assert_equal 31, cookbook.calculate_ore_for('FUEL', 1)
  end

  def test_example2
    reactions = [
      '9 ORE => 2 A',
      '8 ORE => 3 B',
      '7 ORE => 5 C',
      '3 A, 4 B => 1 AB',
      '5 B, 7 C => 1 BC',
      '4 C, 1 A => 1 CA',
      '2 AB, 3 BC, 4 CA => 1 FUEL'
    ]
    cookbook = CookBook.new
    cookbook.add_recipes reactions
    assert_equal 165, cookbook.calculate_ore_for('FUEL', 1)
  end

  def test_example3
    reactions = [
      '157 ORE => 5 NZVS',
      '165 ORE => 6 DCFZ',
      '44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL',
      '12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ',
      '179 ORE => 7 PSHF',
      '177 ORE => 5 HKGWZ',
      '7 DCFZ, 7 PSHF => 2 XJWVT',
      '165 ORE => 2 GPVTF',
      '3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT'
    ]
    cookbook = CookBook.new
    cookbook.add_recipes reactions
    assert_equal 13312, cookbook.calculate_ore_for('FUEL', 1)
  end

  def test_example4
    reactions = [
      '2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG',
      '17 NVRVD, 3 JNWZP => 8 VPVL',
      '53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL',
      '22 VJHF, 37 MNCFX => 5 FWMGM',
      '139 ORE => 4 NVRVD',
      '144 ORE => 7 JNWZP',
      '5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC',
      '5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV',
      '145 ORE => 6 MNCFX',
      '1 NVRVD => 8 CXFTF',
      '1 VJHF, 6 MNCFX => 4 RFSQX',
      '176 ORE => 6 VJHF'
    ]
    cookbook = CookBook.new
    cookbook.add_recipes reactions
    assert_equal 180697, cookbook.calculate_ore_for('FUEL', 1)
  end

  def test_example5
    reactions = [
      '171 ORE => 8 CNZTR',
      '7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL',
      '114 ORE => 4 BHXH',
      '14 VRPVC => 6 BMBT',
      '6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL',
      '6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT',
      '15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW',
      '13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW',
      '5 BMBT => 4 WPTQ',
      '189 ORE => 9 KTJDG',
      '1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP',
      '12 VRPVC, 27 CNZTR => 2 XDBXC',
      '15 KTJDG, 12 BHXH => 5 XCVML',
      '3 BHXH, 2 VRPVC => 7 MZWV',
      '121 ORE => 7 VRPVC',
      '7 XCVML => 6 RJRHP',
      '5 BHXH, 4 VRPVC => 5 LTCX'
    ]
    cookbook = CookBook.new
    cookbook.add_recipes reactions
    assert_equal 2210736, cookbook.calculate_ore_for('FUEL', 1)
  end

  def test_part1
    reactions = IO.readlines('input1.txt')

    cookbook = CookBook.new
    cookbook.add_recipes reactions
    assert_equal 1590844, cookbook.calculate_ore_for('FUEL', 1) # <- correct
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
    source, dest = recipe.split('=>')
    return unless dest =~ /(\d+)\s+(\S+)/

    min_qty = $1.to_i
    name = $2
    @elements[name] = Element.new(name, min_qty)
    @elements[name].built_from(source)
  end

  def calculate_ore_for(target, qty)
    recipe = formula_for(qty, target)
    until recipe.length == 1 do
      recipe = reduce(recipe)
    end
    recipe.first[1]
  end

  # Output formula sorted with max_reactions left first
  def formula_for(qty, desired_element)
    el = @elements[desired_element]
    qty += 1 while (qty % el.min_qty).positive? # Have to create in min quantity multiples
    scale = [qty / el.min_qty, 1].max # Then see if we need to multiply

    el.building_blocks.sort { |b, a| a[0].max_reactions <=> b[0].max_reactions }.map do |component, component_qty|
      [component.name, component_qty * scale]
    end
  end

  # Just expand the first ones with the same max_reactions
  def reduce(recipe)
    front = @elements[recipe.first[0]]
    limit = front.max_reactions
    ones_to_expand = recipe.select { |e| @elements[e[0]].max_reactions == limit }
    remainder = recipe - ones_to_expand

    expanded_recipe = []
    ones_to_expand.map do |name, qty|
      expanded_recipe += formula_for(qty, name)
    end
    expanded_recipe += remainder
    # first = recipe.first
    # element = @elements[first[0]]
    # expanded_recipe = formula_for(first[1], element.name) + recipe[1..-1]
    totaliser = {}
    expanded_recipe.each do |name, qty|
      totaliser[name] ||= 0
      totaliser[name] += qty
    end
    totaliser.map { |k, v| [k, v] }.sort { |b, a| @elements[a[0]].max_reactions <=> @elements[b[0]].max_reactions }
  end
end

#===========================================================
class Element
  attr_reader :building_blocks

  attr_reader :name, :min_qty
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

  def calculate_ore_quantity
    new_blocks = {}
    @building_blocks.each do |el, _min_qty|
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
