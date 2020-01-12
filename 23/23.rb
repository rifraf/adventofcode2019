#
# Advent of Code 2023 day 23
#
require 'pp'
require 'test/unit'
require_relative '../intcode/intcode'

#===========================================================
# Test driver23a
#===========================================================
class Examples23a < Test::Unit::TestCase
  #=========================================================
  def test_nonblocking_input
    program = IO.read('input1.txt').split(',').map(&:to_i)

    send_requests = Queue.new # Collects all requests for messages to be sent

    test_thread = nil
    input = NonBlockingInputStream.new
    output = MessageRequestReceiver.new do |dest, x, y|
      send_requests << [dest, x, y]
      test_thread.kill if dest == 37 # Need to be able to kill intcode
    end

    # Node 0 will start by sending messages to 6 nodes (some of which are the same)
    input << 0
    test_thread = Thread.new { run_intcode(input, output, *program.dup) }
    test_thread.join

    assert_equal [39, 76651, 28154], send_requests.pop
    assert_equal [26, 42571, 28154], send_requests.pop
    assert_equal [26, 85142, 28154], send_requests.pop
    assert_equal [37, 96589, 28154], send_requests.pop
  end

  #=========================================================
  def test_part1
    program = IO.read('input1.txt').split(',').map(&:to_i)

    send_requests = Queue.new # Collects all requests for messages to be sent

    input = 50.times.map { NonBlockingInputStream.new }

    threads = []

    # NIC threads
    50.times do |addr|
      input[addr] << addr
      output = MessageRequestReceiver.new { |dest, x, y| send_requests << [dest, x, y] }
      threads << Thread.new { run_intcode(input[addr], output, *program.dup) }
    end

    threads << Thread.new do
      loop do
        dest, x, y = send_requests.pop
        # p [dest, x, y]
        if dest == 255
          assert_equal 26163, y # <- correct
          threads.each(&:kill) # Suicidal
        end
        input[dest] << x << y
      end
    end

    threads.each(&:join)
  end
end

#===========================================================
# Returns -1 if no data
#===========================================================
class NonBlockingInputStream
  def initialize
    @q = Queue.new
  end

  def shift
    ret = @q.empty? ? -1 : @q.shift
    sleep 0.01 if ret == -1
    ret
  end

  def <<(val)
    @q << val
  end
end

#===========================================================
# Expects data as [dest, X, Y]. Yields it to creator
#===========================================================
class MessageRequestReceiver
  def initialize(&blk)
    @q = Queue.new
    @report = blk
  end

  def shift
    @q.shift
  end

  def <<(val)
    @q << val
    @report.call(@q.pop, @q.pop, @q.pop) if @q.size == 3
  end
end

#===========================================================
# Test driver23b
#===========================================================
class Examples23b < Test::Unit::TestCase
  #=========================================================
  def test_part2
  end
end
