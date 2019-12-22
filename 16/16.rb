#
# Advent of Code 2019 day 16
#
require 'pp'
require 'test/unit'
require_relative '../intcode/intcode'

#===========================================================
# Test driver16a
#===========================================================
class Examples16a < Test::Unit::TestCase

  #=========================================================
  def test_example1
    signal = '15243'.each_char.map(&:to_i)
    pattern = [1, 2, 3]
    assert_equal [1, 0, 6, 4, 6], signal.map { |s| pattern.rotate!; (s * pattern.last) % 10 }
  end

  #=========================================================
  def test_example2
    seed = [0, 1, 0, -1]
    signal = '12345678'.each_char.map(&:to_i)
    patterns = fft_patterns(signal, seed)

    assert_equal [1, 0, -1, 0], patterns[0]
    assert_equal [0, 1, 1, 0, 0, -1, -1, 0], patterns[1][0..7]
    assert_equal [0, 0, 1, 1, 1, 0, 0, 0], patterns[2][0..7]
    assert_equal [0, 0, 0, 1, 1, 1, 1, 0], patterns[3][0..7]
    assert_equal [0, 0, 0, 0, 1, 1, 1, 1], patterns[4][0..7]
    assert_equal [0, 0, 0, 0, 0, 1, 1, 1], patterns[5][0..7]
    assert_equal [0, 0, 0, 0, 0, 0, 1, 1], patterns[6][0..7]
    assert_equal [0, 0, 0, 0, 0, 0, 0, 1], patterns[7][0..7]

    # Phase 1
    result = fft_phase(signal, patterns)
    assert_equal [4, 8, 2, 2, 6, 1, 5, 8], result

    # Phase 2
    result = fft_phase(result, patterns)
    assert_equal [3, 4, 0, 4, 0, 4, 3, 8], result

    # Phase 3
    result = fft_phase(result, patterns)
    assert_equal [0, 3, 4, 1, 5, 5, 1, 8], result

    # Phase 4
    result = fft_phase(result, patterns)
    assert_equal [0, 1, 0, 2, 9, 4, 9, 8], result
  end

  #=========================================================
  def test_example3
    seed = [0, 1, 0, -1]
    signal = '80871224585914546619083218645595'.each_char.map(&:to_i)

    result = signal
    patterns = fft_patterns(signal, seed)
    100.times do
      result = fft_phase(result, patterns)
    end
    assert_equal [2, 4, 1, 7, 6, 1, 7, 6], result[0..7]
  end

  #=========================================================
  def test_example4
    seed = [0, 1, 0, -1]
    signal = '19617804207202209144916044189917'.each_char.map(&:to_i)

    result = signal
    patterns = fft_patterns(signal, seed)
    100.times do
      result = fft_phase(result, patterns)
    end
    assert_equal [7, 3, 7, 4, 5, 4, 1, 8], result[0..7]
  end

  #=========================================================
  def test_example5
    seed = [0, 1, 0, -1]
    signal = '69317163492948606335995924319873'.each_char.map(&:to_i)

    result = signal
    patterns = fft_patterns(signal, seed)
    100.times do
      result = fft_phase(result, patterns)
    end
    assert_equal [5, 2, 4, 3, 2, 1, 3, 3], result[0..7]
  end

  #=========================================================
  # Quite slow (45s) (Now 11s) (Now 7s)
  def test_part1
    seed = [0, 1, 0, -1]
    signal = '59775675999083203307460316227239534744196788252810996056267313158415747954523514450220630777434694464147859581700598049220155996171361500188470573584309935232530483361639265796594588423475377664322506657596419440442622029687655170723364080344399753761821561397734310612361082481766777063437812858875338922334089288117184890884363091417446200960308625363997089394409607215164553325263177638484872071167142885096660905078567883997320316971939560903959842723210017598426984179521683810628956529638813221927079630736290924180307474765551066444888559156901159193212333302170502387548724998221103376187508278234838899434485116047387731626309521488967864391'.each_char.map(&:to_i)

    result = signal
    patterns = fft_patterns(signal, seed)
    100.times do
      result = fft_phase(result, patterns)
    end
    assert_equal [2, 5, 1, 3, 1, 1, 2, 8], result[0..7] # <- correct
    # 25131128
  end

end

#===========================================================
def fft_patterns(signal, seed)
  patterns = []
  signal.length.times do |i|
    pattern = seed.map { |n| [n] * (i + 1) }.flatten.rotate
    patterns << pattern
  end
  patterns
end

#===========================================================
def fft_phase(signal, patterns)
  output = []
  slen = signal.length
  slen.times do |i|
    index = -1
    pattern = patterns[i]
    plen = pattern.length
    output << signal.map do |s|
      index += 1
      index = 0 if index >= plen
      s * pattern[index]
    end.reduce(&:+).abs % 10
  end
  output
end

#===========================================================
# Test driver16b
#===========================================================
class Examples16b < Test::Unit::TestCase

  #=========================================================
  def test_extending_signal
    seed = [0, 1, 0, -1]
    signal = '12345678'.each_char.map(&:to_i)

    result = signal
    patterns = fft_patterns(signal, seed)
    100.times do
      result = fft_phase(result, patterns)
    end

    p result
    assert_equal [2, 3, 8, 4, 5, 6, 7, 8], result[0..7]

    signal = signal * 2
    result = signal
    patterns = fft_patterns(signal, seed)
    100.times do
      result = fft_phase(result, patterns)
    end
    # p signal
    # pp patterns
    p result

    signal = signal * 2
    result = signal
    patterns = fft_patterns(signal, seed)
    100.times do
      result = fft_phase(result, patterns)
    end
    # p signal
    # pp patterns
    p result
  end

  # #=========================================================
  # def test_part2
  #   seed = [0, 1, 0, -1]
  #   signal = '59775675999083203307460316227239534744196788252810996056267313158415747954523514450220630777434694464147859581700598049220155996171361500188470573584309935232530483361639265796594588423475377664322506657596419440442622029687655170723364080344399753761821561397734310612361082481766777063437812858875338922334089288117184890884363091417446200960308625363997089394409607215164553325263177638484872071167142885096660905078567883997320316971939560903959842723210017598426984179521683810628956529638813221927079630736290924180307474765551066444888559156901159193212333302170502387548724998221103376187508278234838899434485116047387731626309521488967864391'.each_char.map(&:to_i)
  #   signal *= 10_000

  #   assert_equal 5977567, (signal[0] * 1_000_000) + (signal[1] * 100_000) + (signal[2] * 10_000) + (signal[3] * 1_000) + (signal[4] * 100) + (signal[5] * 10) + (signal[6] * 1)
  #   result = signal
  #   patterns = fft_patterns(signal, seed)
  #   1.times do
  #     result = fft_phase(result, patterns)
  #   end
  #   p result
  #   # assert_equal [2, 4, 1, 7, 6, 1, 7, 6], result[0..7]
  # end

end
