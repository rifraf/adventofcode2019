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
  def xtest_route_removal
    map = Map.new

    routes = {
      '@' => [['A', 2], ['a', 3], ['X', 99]],
      'A' => [['@', 2], ['b', 3]],
      'a' => [['@', 3], ['c', 3]],
      'X' => [['@', 99]]
    }
    expect = {
      'A' => [['b', 3], ['a', 5], ['X', 101]],
      'a' => [['c', 3], ['A', 5], ['X', 102]],
      'X' => [['A', 101], ['a', 102]]
    }

    assert_equal expect, map._routes_removing('@', routes)
  end

  # ========================================================
  def test_example1
    maze_lines = [
      '#########',
      '#b.A.@.a#',
      '#########'
    ]

    map = Map.new
    map.add_image maze_lines
    map.draw

    routes = {}
    routes['@'] = map.routes_for(map.entrance)
    map.items.each do |id, location|
      routes[id] = map.routes_for(location)
    end

    assert_equal [['A', 2], ['a', 2]], routes['@']
    assert_equal [['@', 2]], routes['a']
    assert_equal [['A', 2]], routes['b']
    assert_equal [['b', 2], ['@', 2]], routes['A']

    assert_equal 8, map.shortest_steps_for(map.keys, map.item_routes, '@', 0)
  end

  # ========================================================
  def test_example2
    maze_lines = [
      '########################',
      '#f.D.E.e.C.b.A.@.a.B.c.#',
      '######################.#',
      '#d.....................#',
      '########################'
    ]

    map = Map.new
    map.add_image maze_lines
    map.draw

    routes = {}
    routes['@'] = map.routes_for(map.entrance)
    map.items.each do |id, location|
      routes[id] = map.routes_for(location)
    end

    assert_equal [['A', 2], ['a', 2]], routes['@']
    assert_equal [['B', 2], ['d', 24]], routes['c']
    assert_equal [['D', 2]], routes['f']

    assert_equal 86, map.shortest_steps_for(map.keys, map.item_routes, '@', 0)
  end

  # ========================================================
  def test_example3
    maze_lines = [
      '########################',
      '#...............b.C.D.f#',
      '#.######################',
      '#.....@.a.B.c.d.A.e.F.g#',
      '########################'
    ]

    map = Map.new
    map.add_image maze_lines
    map.draw

    # b, a, c, d, f, e, g
    assert_equal 132, map.shortest_steps_for(map.keys, map.item_routes, '@', 0)
  end

  # ========================================================
  def ztest_example4
    maze_lines = [
      '#################',
      '#i.G..c...e..H.p#',
      '########.########',
      '#j.A..b...f..D.o#',
      '########@########',
      '#k.E..a...g..B.n#',
      '########.########',
      '#l.F..d...h..C.m#',
      '#################'
    ]

    map = Map.new
    map.add_image maze_lines
    map.draw

# pp map.item_routes
# def shortest_steps_for(keys, routes, origin, current_steps, best_result = nil)
    routes = map._routes_removing('@', map.item_routes)
pp routes
    best_result = nil
    map.item_routes['@'].select { |k, s| k =~ /[a-z]/}.each do |k, s|
      puts "Start with #{k}/#{s} best = #{best_result}"
      next_route = map._routes_removing(k.upcase, routes)
      result = map.shortest_steps_for(map.keys - [k], next_route, k, s, best_result)
      puts "Best for #{k} is #{result}"
      best_result = if best_result
                      [best_result, result].min
                    else
                      result
                    end
    end
    # Gets 136 as best but never completes (in 24h)?
    # a, f, b, j, g, n, h, d, l, o, e, p, c, i, k, m
    # assert_equal 136, map.shortest_steps_for(map.keys, map.item_routes, '@', 0)
  end

  # ========================================================
  def test_example5
    maze_lines = [
      '########################',
      '#@..............ac.GI.b#',
      '###d#e#f################',
      '###A#B#C################',
      '###g#h#i################',
      '########################'
    ]

    map = Map.new
    map.add_image maze_lines
    map.draw

    # a, c, f, i, d, g, b, e, h
    assert_equal 81, map.shortest_steps_for(map.keys, map.item_routes, '@', 0)
  end

  # ========================================================
  def test_part1
    maze_lines = IO.readlines('input1.txt')

    map = Map.new
    map.add_image maze_lines
    map.draw

    routes = map._routes_removing('@', map.item_routes)
pp routes
    best_result = nil
    map.item_routes['@'].select { |k, s| k =~ /[a-z]/}.each do |k, s|
      puts "Start with #{k}/#{s} best = #{best_result}"
      next_route = map._routes_removing(k.upcase, routes)
      result = map.shortest_steps_for(map.keys - [k], next_route, k, s, best_result)
      puts "Best for #{k} is #{result}"
      best_result = if best_result
                      [best_result, result].min
                    else
                      result
                    end
    end
    # Gets down to 3274 eventually but runs out of memory
    # assert_equal 0, map.shortest_steps_for(map.keys, map.item_routes, '@', 0)
  end

end

#===========================================================
class Map

  attr_reader :entrance, :keys, :doors, :items

  # --------------------------------------------------------
  def initialize
    @pixels = {}
    @walls = []
    @keys = []
    @doors = {}
    @entrance = [0, 0]
    @items = {}
  end

  # --------------------------------------------------------
  def add_image(maze_lines)
    y = 0
    maze_lines.each do |line|
      x = 0
      line.strip.each_char do |c|
        @pixels[[x, y]] = c
        case c
        when '@'
          @entrance = [x, y]
        when '#'
          @walls << [x, y]
        when /[a-z]/
          @keys << c
          @items[c] = [x, y]
        when /[A-Z]/
          @doors[c] = [x, y]
          @items[c] = [x, y]
        end
        @max_x = x
        x += 1
      end
      @max_y = y
      y += 1
    end
  end

  # --------------------------------------------------------
  def draw
    puts
    (0..@max_y).each do |y|
      (0..@max_x).each do |x|
        print @pixels[[x, y]]
      end
      puts
    end
    puts
  end

  # --------------------------------------------------------
  def routes_for(loc)
    routes = []
    visited = {
      loc => 0
    }
    1000.times do |i|
      break unless _colourize(visited, i, i + 1) { |item, distance| routes << [item, distance] unless routes.find { |r| r[0] == item } }
    end
    routes
  end

  # --------------------------------------------------------
  def item_routes
    partial_routes = { '@' => routes_for(@entrance) }
    @items.each do |id, location|
      partial_routes[id] = routes_for(location)
    end
    partial_routes
  end

  # --------------------------------------------------------
  def shortest_steps_for(keys, routes, origin, current_steps, best_result = nil) #, indent = '', tracker = '')
    # p [:shortest_steps_for, origin, keys, current_steps]
    # pp routes
    # return [] if keys.empty?
    # possible_results = []
    # best_result = nil

#    tracker += origin
    # connections = routes[origin] # e.g. [['A', 2], ['a', 3]]
    # options = connections.map { |x,y| x }
    # print "\n#{indent}[#{tracker}] Depth #{current_steps}. Options #{options}"
#    print "\n#{indent}[#{tracker}]"

    # if options.select{ |item| options.count(item) > 1}.any?
    #   puts "duplicate options"
    #   pp connections
    #   exit 1
    # end
#    indent += '  '

    routes[origin].
      select { |id, step| (id =~ /[a-z]/) && (best_result.nil? || ((step + current_steps < best_result))) }.
      each do |id, step| # e.g. ['A', 2] in steps order
      # print " Looking at #{id}. Depth #{this_depth} (#{best_result})"

      this_depth = step + current_steps
      # if best_result && (this_depth >= best_result)
      #   # print "\n#{indent} ---------------------------- Abandon at #{id} because #{this_depth} >= #{best_result}"
      #   break # Other connections are as far or further
      # end

      # Door?
      # if id =~ /[A-Z]/
      #   # print "\n#{indent} Blocked by door #{id}"
      #   next
      # end

      next_route = _routes_removing(origin, routes)
      # current_keys = keys.dup
      current_keys = keys

      # Key?
      if id =~ /[a-z]/
        # print " Got key #{id}"
        # print " Unlock door #{id.upcase}"
        next_route = _routes_removing(id.upcase, next_route)

        current_keys = current_keys.dup
        current_keys.delete(id)
        if current_keys.empty?
          best_result = if best_result
                          [best_result, this_depth].min
                        else
                          this_depth
                        end
          print "\n---------------------------- All found: #{id} = #{this_depth}"
          break # Next ones won't be closer
        end
      end

      result = shortest_steps_for(current_keys, next_route, id, this_depth, best_result) #, indent, tracker)
      next unless result

      best_result = if best_result
                      [best_result, result].min
                    else
                      result
                    end

    end

    best_result
  end

  # --------------------------------------------------------
  def _routes_removing(origin, routes)
    # e.g.
    #  '@' => [['A', 2], ['a', 3]]
    #  'A' => [['@', 2], ['b', 3]]
    #  'a' => [['@', 2], ['c', 3]]
    # becomes
    #  'A' => [['a', 5], ['b', 3]]
    #  'a' => [['A', 5], ['c', 3]]

    # Deep-enough copy
    new_routes = {}
    routes.each do |k, v|
      new_routes[k] = v.dup
    end

    new_routes.delete origin
    new_routes.each do |id1, steps|
      steps.each do |id2, addition|
        if id2 == origin
          routes[origin].each do |id3, val|
            steps << [id3, addition + val] if id3 != id1
          end
        end
      end
      steps.delete_if { |k, _v| k == origin }
      steps.delete_if { |k, v| steps.find { |k2, v2| (k == k2) && (v2 < v) } }
      steps.sort! { |a, b| a[1] <=> b[1] }.uniq!
    end

    # puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    # pp routes
    # puts "Remove #{origin}"
    # pp new_routes
    # puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    new_routes
  end

  # --------------------------------------------------------
  def _colourize(visits, from, to)
    candidates = visits.select { |_loc, colour| colour == from }
    return false unless candidates.any?

    candidates.each do |loc, _colour|
      # p [:candidate, loc, colour]
      [ [loc[0] - 1, loc[1]], [loc[0] + 1, loc[1]], [loc[0], loc[1] - 1], [loc[0], loc[1] + 1] ].each do |new_loc|
        next unless visits[new_loc].nil? # Visited

        if @pixels[new_loc] == '.' # mark corridor
          visits[new_loc] = to
          next
        end

        yield @pixels[new_loc], to unless @pixels[new_loc] == '#' # Report item
      end
    end
    true
  end
end
