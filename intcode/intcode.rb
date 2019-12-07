#===========================================================
# Shared implementation of intcode
#===========================================================
def run_intcode(input, output, *program)
  index = 0
  while (program[index] % 100) != 99
    instruction = program[index]
    opcode = instruction % 100
    param1_mode = (instruction / 100) % 10
    param2_mode = (instruction / 1_000) % 10
    param3_mode = (instruction / 10_000) % 10

    case opcode
    when 1
      sum = read_param(1, program, index, param1_mode) + read_param(2, program, index, param2_mode)
      write_param(3, program, index, param3_mode, sum)
      index += 4
    when 2
      prod = read_param(1, program, index, param1_mode) * read_param(2, program, index, param2_mode)
      write_param(3, program, index, param3_mode, prod)
      index += 4
    when 3 # Store input
      value = input.shift
      write_param(1, program, index, param1_mode, value)
      index += 2
    when 4 # output first parameter
      value = read_param(1, program, index, param1_mode)
      output << value
      index += 2
    when 5 # is jump-if-true
      # if the first parameter is non-zero, it sets the instruction pointer to the value from the second parameter. Otherwise, it does nothing.
      value = read_param(1, program, index, param1_mode)
      if value.zero?
        index += 3
      else
        index = read_param(2, program, index, param2_mode)
      end
    when 6 # is jump-if-false
      # if the first parameter is zero, it sets the instruction pointer to the value from the second parameter. Otherwise, it does nothing.
      value = read_param(1, program, index, param1_mode)
      if value.zero?
        index = read_param(2, program, index, param2_mode)
      else
        index += 3
      end
    when 7 # less than
      # if the first parameter is less than the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
      value = if read_param(1, program, index, param1_mode) < read_param(2, program, index, param2_mode)
                1
              else
                0
              end
      write_param(3, program, index, param3_mode, value)
      index += 4
    when 8 # equals
      # if the first parameter is equal to the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
      value = if read_param(1, program, index, param1_mode) == read_param(2, program, index, param2_mode)
                1
              else
                0
              end
      write_param(3, program, index, param3_mode, value)
      index += 4
    else
      puts
      puts "Invalid OP #{program[index]} at #{index}"
      exit(1)
    end
  end
  program
end

#===========================================================
def read_param(num, program, index, mode)
  case mode
  when 0
    program[program[index + num]]
  when 1
    program[index + num]
  end
end

#===========================================================
def write_param(num, program, index, _mode, value)
  program[program[index + num]] = value
end
