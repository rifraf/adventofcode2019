#
# Advent of Code 2019 day 4
#
require 'pp'
require 'test/unit'

NEGATIVE_CHAR = ' '.freeze

#===========================================================
# Test driver1
#===========================================================
class Examples1 < Test::Unit::TestCase

  # Just prove we can use comparison on number characters
  def test_ruby_compares
    assert '1' < '2'
    assert '0' < '1'
    assert NEGATIVE_CHAR < '0' # a character that is less than numerics
  end

  def test_example1
    assert valid_password('111111')
  end

  def test_example2
    assert !valid_password('223450')
  end

  def test_example3
    assert !valid_password('123789')
  end

end

#===========================================================
def valid_password(password)
  return false unless password =~ /^\d\d\d\d\d\d$/ # It is a six-digit number

  last_char = NEGATIVE_CHAR
  seen_a_double = false
  password.each_char do |c|
    return false if last_char > c # Going from left to right, the digits never decrease
    seen_a_double = true if c == last_char
    last_char = c
  end
  return false unless seen_a_double # Two adjacent digits are the same
  true
end

#===========================================================
brute_force_range = (134_564..585_159)
valid_passwords = []
brute_force_range.each do |n|
  valid_passwords << n if valid_password(n.to_s)
end

# p valid_passwords
puts "#{valid_passwords.length} valid passwords part 1"

#===========================================================
# Test driver2
#===========================================================
class Examples2 < Test::Unit::TestCase

  def test_example1
    assert alternate_valid_password('112233')
  end

  def test_example2
    assert !alternate_valid_password('123444')
  end

  def test_example3
    assert alternate_valid_password('111122')
  end

end

#===========================================================
def alternate_valid_password(password)
  return false unless valid_password(password)
  padded = " #{password} "
  return true if padded =~ /[^0]00[^0]/
  return true if padded =~ /[^1]11[^1]/
  return true if padded =~ /[^2]22[^2]/
  return true if padded =~ /[^3]33[^3]/
  return true if padded =~ /[^4]44[^4]/
  return true if padded =~ /[^5]55[^5]/
  return true if padded =~ /[^6]66[^6]/
  return true if padded =~ /[^7]77[^7]/
  return true if padded =~ /[^8]88[^8]/
  return true if padded =~ /[^9]99[^9]/
  false
end

valid_passwords = []
brute_force_range.each do |n|
  valid_passwords << n if alternate_valid_password(n.to_s)
end

# p valid_passwords
puts "#{valid_passwords.length} valid passwords part 2" # <- 1306
