#
# Advent of Code 2019 day 12
#
require 'pp'
require 'test/unit'

#===========================================================
# Test driver12a
#===========================================================
class Examples12a < Test::Unit::TestCase
  InitialLocations = [
    [-1, 0, 2],
    [2, -10, -7],
    [4, -8, 8],
    [3, 5, -1]
  ].freeze

  #=========================================================
  def test_start_conditions
    system = OrbitalSystem.new
    system.add_moons(InitialLocations)

    system.moons.each_with_index do |moon, index|
      assert_equal InitialLocations[index], moon.position
      assert_equal [0, 0, 0], moon.velocity
    end
  end

  #=========================================================
  def test_one_step
    system = OrbitalSystem.new
    system.add_moons(InitialLocations)

    system.apply_gravity
    assert_equal [-1, 0, 2], system.moons[0].position
    assert_equal [3, -1, -1], system.moons[0].velocity

    system.apply_velocity
    assert_equal [2, -1, 1], system.moons[0].position
    assert_equal [3, -1, -1], system.moons[0].velocity
  end

  #=========================================================
  def test_10_steps
    system = OrbitalSystem.new
    system.add_moons(InitialLocations)

    10.times do
      system.apply_gravity
      system.apply_velocity
    end

    assert_equal [2, 1, -3], system.moons[0].position
    assert_equal [-3, -2, 1], system.moons[0].velocity
    assert_equal [1, -8, 0], system.moons[1].position
    assert_equal [-1, 1, 3], system.moons[1].velocity
    assert_equal [3, -6, 1], system.moons[2].position
    assert_equal [3, 2, -3], system.moons[2].velocity
    assert_equal [2, 0, 4], system.moons[3].position
    assert_equal [1, -1, -1], system.moons[3].velocity

    assert_equal  6, system.moons[0].potential_energy
    assert_equal  6, system.moons[0].kinetic_energy
    assert_equal  9, system.moons[1].potential_energy
    assert_equal  5, system.moons[1].kinetic_energy
    assert_equal 10, system.moons[2].potential_energy
    assert_equal  8, system.moons[2].kinetic_energy
    assert_equal  6, system.moons[3].potential_energy
    assert_equal  3, system.moons[3].kinetic_energy

    total = system.moons.map { |m| m.potential_energy * m.kinetic_energy }.reduce(:+)

    puts "Total energy #{total}"
    assert_equal 179, total
  end
end

#===========================================================
# Test driver12b
#===========================================================
class Examples12b < Test::Unit::TestCase
  InitialLocations = [
    [-8, -10, 0],
    [5, 5, 10],
    [2, -7, 3],
    [9, -8, -3]
  ].freeze

  #=========================================================
  def test_100_steps
    system = OrbitalSystem.new
    system.add_moons(InitialLocations)

    100.times do
      system.apply_gravity
      system.apply_velocity
    end

    total = system.moons.map { |m| m.potential_energy * m.kinetic_energy }.reduce(:+)
    puts "Total energy #{total}"
    assert_equal 1940, total
  end
end

#===========================================================
# Test driver12_part1
#===========================================================
class Examples12_part1 < Test::Unit::TestCase
  InitialLocations = [
    [-4, 3, 15],
    [-11, -10, 13],
    [2, 2, 18],
    [7, -1, 0]
  ].freeze

  #=========================================================
  def test_1000_steps
    system = OrbitalSystem.new
    system.add_moons(InitialLocations)

    1000.times do
      system.apply_gravity
      system.apply_velocity
    end

    total = system.moons.map { |m| m.potential_energy * m.kinetic_energy }.reduce(:+)
    puts "Part 1 total energy #{total}"
    assert_equal 7722, total # <- correct

    assert_equal 7722, system.energy_of_moons
  end
end

#===========================================================
class OrbitalSystem
  attr_reader :moons

  def initialize
    @moons = []
  end

  def add_moons(locations)
    locations.map do |location|
      @moons << Moon.new(location.dup)
    end
  end

  def apply_gravity
    @moons.each { |moon| moon.apply_gravity(@moons) }
  end

  def apply_velocity
    @moons.each(&:apply_velocity)
  end

  def energy_of_moons
    @moons.map { |m| m.potential_energy * m.kinetic_energy }.reduce(:+)
  end

  def moon_state_signature
    sig = ''
    @moons.each do |m|
      sig << m.state_signature
    end
    sig
  end
end

#===========================================================
class Moon
  attr_reader :position, :velocity

  def initialize(start_point)
    @position = start_point
    @velocity = [0, 0, 0]
  end

  def state_signature
    "#{@position}+#{velocity}"
  end

  def apply_gravity(moons_in_system)
    moons_in_system.reject { |moon| self == moon }.each do |moon|
      3.times do |i|
        @velocity[i] += 1 if @position[i] < moon.position[i]
        @velocity[i] -= 1 if @position[i] > moon.position[i]
      end
    end
  end

  def apply_velocity
    3.times do |i|
      @position[i] += @velocity[i]
    end
  end

  def potential_energy
    @position[0].abs + @position[1].abs + @position[2].abs
  end

  def kinetic_energy
    @velocity[0].abs + @velocity[1].abs + @velocity[2].abs
  end
end

#===========================================================
# Test driver12_2a
#===========================================================
class Examples12_2a < Test::Unit::TestCase
  InitialLocations = [
    [-1, 0, 2],
    [2, -10, -7],
    [4, -8, 8],
    [3, 5, -1]
  ].freeze

  #=========================================================
  def test_repeat1_v1
    system = OrbitalSystem.new
    system.add_moons(InitialLocations)

    initial_energy = system.energy_of_moons
    initial_signature = system.moon_state_signature

    iteration = 0
    loop do
      system.apply_gravity
      system.apply_velocity
      iteration += 1
      next unless initial_energy == system.energy_of_moons

      puts "Same energy at iteration #{iteration}"
      if initial_signature == system.moon_state_signature
        puts " Same state at iteration #{iteration}"
        break
      end
    end
    assert_equal 2772, iteration
  end

  #=========================================================
  def test_repeat1_v2
    system = OrbitalSystem.new
    system.add_moons(InitialLocations)

    puts "Example 1"
    assert_equal 2772, calc_repeats(system)
  end

  #=========================================================
  def test_repeat2_v2
    system = OrbitalSystem.new
    system.add_moons([
                       [-8, -10, 0],
                       [5, 5, 10],
                       [2, -7, 3],
                       [9, -8, -3]
                     ])

    puts "Example 2"
    assert_equal 4686774924, calc_repeats(system)
  end
end

#===========================================================
def calc_repeats(system)
  x_starts  = system.moons.map { |m| [m.position[0], m.velocity[0]] }
  x_repeats = system.moons.map { |_m| [] }
  y_starts  = system.moons.map { |m| [m.position[1], m.velocity[1]] }
  y_repeats = system.moons.map { |_m| [] }
  z_starts  = system.moons.map { |m| [m.position[2], m.velocity[2]] }
  z_repeats = system.moons.map { |_m| [] }
  ready     = system.moons.map { |_m| false }

  iteration = 0
  loop do
    system.apply_gravity
    system.apply_velocity
    iteration += 1

    system.moons.each_with_index do |moon, index|
      if x_starts[index] == [moon.position[0], moon.velocity[0]]
        x_repeats[index] << iteration
        # ready[index] = true if (y_repeats[index].any?) && (z_repeats[index].any?)
        ready[index] = true if (y_repeats[index].include?(iteration)) && (z_repeats[index].include?(iteration))
      end

      if y_starts[index] == [moon.position[1], moon.velocity[1]]
        y_repeats[index] << iteration
        # ready[index] = true if (x_repeats[index].any?) && (z_repeats[index].any?)
        ready[index] = true if (x_repeats[index].include?(iteration)) && (z_repeats[index].include?(iteration))
      end

      if z_starts[index] == [moon.position[2], moon.velocity[2]]
        z_repeats[index] << iteration
        # ready[index] = true if (x_repeats[index].any?) && (y_repeats[index].any?)
        ready[index] = true if (x_repeats[index].include?(iteration)) && (y_repeats[index].include?(iteration))
      end
    end

    break if ready.all?
  end

  # To find repeat, take first element in one with fewest repeats
  pp x_repeats.sort { |a, b| a.length <=> b.length }
  pp y_repeats.sort { |a, b| a.length <=> b.length }
  pp z_repeats.sort { |a, b| a.length <=> b.length }

  x_repeat = x_repeats.sort { |a, b| a.length <=> b.length }[0][0]
  y_repeat = y_repeats.sort { |a, b| a.length <=> b.length }[0][0]
  z_repeat = z_repeats.sort { |a, b| a.length <=> b.length }[0][0]
  lcm = [x_repeat, y_repeat, z_repeat].reduce(1, :lcm)
  puts "Repeats: #{[x_repeat, y_repeat, z_repeat]}"
  puts " -> #{lcm}"
  lcm
end

#===========================================================
# Test driver12_2
#===========================================================
class Examples12_2 < Test::Unit::TestCase
  InitialLocations = [
    [-4, 3, 15],
    [-11, -10, 13],
    [2, 2, 18],
    [7, -1, 0]
  ].freeze

  #=========================================================
  def test_part2
    locations = [
      [-4, 3, 15],
      [-11, -10, 13],
      [2, 2, 18],
      [7, -1, 0]
    ]

    system = OrbitalSystem.new
    system.add_moons(locations)

    puts "Part 2"
    #            1366156979 <- low
    #           27048220958 <- low
    assert_equal 13524110479, calc_repeats(system)
  end
end
