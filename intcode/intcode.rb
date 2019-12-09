#===========================================================
# Shared implementation of intcode
#===========================================================
def run_intcode(input, output, *program)
  index = 0
  sda_base = 0
  while (program[index] % 100) != 99
    instruction = program[index]
    opcode = instruction % 100
    param1_mode = (instruction / 100) % 10
    param2_mode = (instruction / 1_000) % 10
    param3_mode = (instruction / 10_000) % 10

    # p [index, opcode, param1_mode, param2_mode, param3_mode, sda_base]

    case opcode
    when 1 # +
      sum = read_param(1, program, index, param1_mode, sda_base) + read_param(2, program, index, param2_mode, sda_base)
      write_param(3, program, index, param3_mode, sda_base, sum)
      index += 4
    when 2 # *
      prod = read_param(1, program, index, param1_mode, sda_base) * read_param(2, program, index, param2_mode, sda_base)
      write_param(3, program, index, param3_mode, sda_base, prod)
      index += 4
    when 3 # Store input
      value = input.shift
      write_param(1, program, index, param1_mode, sda_base, value)
      index += 2
    when 4 # output first parameter
      value = read_param(1, program, index, param1_mode, sda_base)
      output << value
      index += 2
    when 5 # is jump-if-true
      # if the first parameter is non-zero, it sets the instruction pointer to the value from the second parameter. Otherwise, it does nothing.
      value = read_param(1, program, index, param1_mode, sda_base)
      if value.zero?
        index += 3
      else
        index = read_param(2, program, index, param2_mode, sda_base)
      end
    when 6 # is jump-if-false
      # if the first parameter is zero, it sets the instruction pointer to the value from the second parameter. Otherwise, it does nothing.
      value = read_param(1, program, index, param1_mode, sda_base)
      if value.zero?
        index = read_param(2, program, index, param2_mode, sda_base)
      else
        index += 3
      end
    when 7 # less than
      # if the first parameter is less than the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
      value = if read_param(1, program, index, param1_mode, sda_base) < read_param(2, program, index, param2_mode, sda_base)
                1
              else
                0
              end
      write_param(3, program, index, param3_mode, sda_base, value)
      index += 4
    when 8 # equals
      # if the first parameter is equal to the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
      value = if read_param(1, program, index, param1_mode, sda_base) == read_param(2, program, index, param2_mode, sda_base)
                1
              else
                0
              end
      write_param(3, program, index, param3_mode, sda_base, value)
      index += 4
    when 9 # adjusts the relative base
      value = read_param(1, program, index, param1_mode, sda_base)
      sda_base += value
      index += 2
    else
      puts
      puts "Invalid OP #{program[index]} at #{index}"
      exit(1)
    end
  end
  # p [index, opcode, param1_mode, param2_mode, param3_mode, sda_base]

  program
end

#===========================================================
def read_param(num, program, index, mode, base)
  case mode
  when 0
    program[program[index + num]] || 0
  when 1
    program[index + num] || 0
  when 2
    program[base + program[index + num]] || 0
  end
end

#===========================================================
def write_param(num, program, index, mode, base, value)
  case mode
  when 0
    program[program[index + num]] = value
  when 1
    program[index + num] = value
  when 2
    program[base + program[index + num]] = value
  end
end
