#
# Advent of Code 2019 day 22
#
require 'pp'
require 'test/unit'

#===========================================================
# Test driver22a
#===========================================================
class Examples22a < Test::Unit::TestCase
  #=========================================================
  def test_deal_into_new_stack
    deck = Deck.new(10)

    assert_equal [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], deck.cards
    deck.deal_into_new_stack
    assert_equal [9, 8, 7, 6, 5, 4, 3, 2, 1, 0], deck.cards
  end

  #=========================================================
  def test_cut3
    deck = Deck.new(10)

    assert_equal [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], deck.cards
    deck.cut(3)
    assert_equal [3, 4, 5, 6, 7, 8, 9, 0, 1, 2], deck.cards
  end

  #=========================================================
  def test_cut_minus4
    deck = Deck.new(10)

    assert_equal [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], deck.cards
    deck.cut(-4)
    assert_equal [6, 7, 8, 9, 0, 1, 2, 3, 4, 5], deck.cards
  end

  #=========================================================
  def test_increment_3
    deck = Deck.new(10)

    assert_equal [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], deck.cards
    deck.increment(3)
    assert_equal [0, 7, 4, 1, 8, 5, 2, 9, 6, 3], deck.cards
  end

  #=========================================================
  def test_example1
    deck = Deck.new(10)

    deck.increment(7)
    deck.deal_into_new_stack
    deck.deal_into_new_stack
    assert_equal [0, 3, 6, 9, 2, 5, 8, 1, 4, 7], deck.cards
  end

  #=========================================================
  def test_example2
    deck = Deck.new(10)

    deck.cut(6)
    deck.increment(7)
    deck.deal_into_new_stack
    assert_equal [3, 0, 7, 4, 1, 8, 5, 2, 9, 6], deck.cards
  end

  #=========================================================
  def test_example3
    deck = Deck.new(10)

    deck.increment(7)
    deck.increment(9)
    deck.cut(-2)
    assert_equal [6, 3, 0, 7, 4, 1, 8, 5, 2, 9], deck.cards
  end

  #=========================================================
  def test_example4
    deck = Deck.new(10)

    deck.deal_into_new_stack
    deck.cut(-2)
    deck.increment(7)
    deck.cut(8)
    deck.cut(-4)
    deck.increment(7)
    deck.cut(3)
    deck.increment(9)
    deck.increment(3)
    deck.cut(-1)
    assert_equal [9, 2, 5, 8, 1, 4, 7, 0, 3, 6], deck.cards
  end

  #=========================================================
  def test_part1
    deck = Deck.new(10_007)

    manipulate_deck!(deck)
    assert_equal 2322, deck.cards.index(2019) # <- correct
  end
end

#===========================================================
class Deck

  attr_reader :cards

  #---------------------------------------------------------
  def initialize(quantity)
    @quantity = quantity
    @cards = Array.new(quantity)
    quantity.times { |index| @cards[index] = index }
  end

  #---------------------------------------------------------
  def deal_into_new_stack
    @cards.reverse!
  end

  #---------------------------------------------------------
  def cut(num)
    return if num.zero? # No-op

    bit = if num > 0
            @cards.slice!(0, num)
          else
            @cards.slice!(0, @quantity + num)
          end
    @cards += bit
  end

  #---------------------------------------------------------
  def increment(step_size)
    next_cards = Array.new(@quantity)
    index = 0
    while (top = @cards.shift)
      next_cards[index] = top
      index += step_size
      index -= @quantity if index >= @quantity
    end
    @cards = next_cards
  end
end

#===========================================================
def manipulate_deck!(deck)
  deck.cut(7167)
  deck.increment(59)
  deck.cut(4836)
  deck.deal_into_new_stack
  deck.increment(9)
  deck.cut(-4087)
  deck.increment(68)
  deck.cut(227)
  deck.increment(71)
  deck.cut(-8524)
  deck.deal_into_new_stack
  deck.increment(17)
  deck.cut(441)
  deck.increment(30)
  deck.cut(-6438)
  deck.increment(24)
  deck.deal_into_new_stack
  deck.increment(72)
  deck.deal_into_new_stack
  deck.increment(51)
  deck.cut(2636)
  deck.increment(59)
  deck.deal_into_new_stack
  deck.cut(5477)
  deck.deal_into_new_stack
  deck.cut(-7129)
  deck.increment(54)
  deck.cut(-9355)
  deck.increment(64)
  deck.cut(6771)
  deck.increment(71)
  deck.cut(1585)
  deck.increment(61)
  deck.cut(7973)
  deck.increment(62)
  deck.cut(5741)
  deck.increment(42)
  deck.cut(6630)
  deck.increment(12)
  deck.cut(2023)
  deck.increment(68)
  deck.cut(-3696)
  deck.increment(5)
  deck.cut(312)
  deck.increment(40)
  deck.deal_into_new_stack
  deck.increment(4)
  deck.deal_into_new_stack
  deck.increment(50)
  deck.cut(-1789)
  deck.increment(58)
  deck.cut(-902)
  deck.increment(71)
  deck.cut(-6724)
  deck.increment(43)
  deck.deal_into_new_stack
  deck.increment(30)
  deck.cut(-5158)
  deck.increment(3)
  deck.deal_into_new_stack
  deck.cut(-1662)
  deck.deal_into_new_stack
  deck.cut(-8906)
  deck.deal_into_new_stack
  deck.increment(35)
  deck.cut(-562)
  deck.deal_into_new_stack
  deck.cut(5473)
  deck.increment(53)
  deck.cut(618)
  deck.increment(21)
  deck.cut(-9703)
  deck.deal_into_new_stack
  deck.increment(62)
  deck.cut(3906)
  deck.increment(8)
  deck.cut(-978)
  deck.increment(4)
  deck.cut(139)
  deck.increment(2)
  deck.cut(4352)
  deck.increment(66)
  deck.cut(255)
  deck.deal_into_new_stack
  deck.increment(18)
  deck.deal_into_new_stack
  deck.increment(33)
  deck.cut(9829)
  deck.deal_into_new_stack
  deck.increment(7)
  deck.cut(-512)
  deck.increment(33)
  deck.cut(3188)
  deck.increment(46)
  deck.cut(-6352)
  deck.deal_into_new_stack
  deck.cut(-1271)
  deck.increment(9)
  deck.cut(-4747)
  deck.increment(6)
end
