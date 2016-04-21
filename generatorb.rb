require 'optparse'
require 'ostruct'


#process the expression in the square brackets,
#returning the length of the expression or -1
#if invalid
def process_bracket_expression(regex, quantity)
  int len = 0
  
  #check if range
  while len <= regex.length && regex[len] != ']'
    if regex[len] != '-' and regex[len + 1] == '-' and regex[len + 2] != ']'
      if regex[len].ord < regex[len + 2].ord
        add_sequence(regex[len]..regex[len + 2]).to_a.join
        len += 3
      else
        len = -1
        break
      end
    else        
      if operator_length(regex[len]) == 2
        process_metacharacter(metacharacter, quantity, codes)
      else
        add_single(regex[len])
      end
    end
  end
  
  return len
end

# if a valid quantifier exists, return the quantity as well as the step of the quantifier (e.g. how many characters it takes starting at the opening brace),
# otherwise return -1
# brace_position: index in the regular expression of the open brace
def parse_quantifier_structure(regex, brace_position)
  case regex[brace_position]
  when '{'
    #handle {n} and {,n} and {n,m} occurrences 
    if brace_position < regex.length
      close_brace = regex.index('}',brace_position)
      if close_brace != nil
        quantifier = regex[brace_position + 1..close_brace]
        case quantifier
        when /\d+,\d+/
          limits = quantifier.split(',')
          return {:quantity => rand(limits[0].to_i..limits[1].to_i), :step => close_brace - brace_position + 1}
        when /,\d+/
          return {:quantity => rand(0..quantifier[1,].to_i), :step => close_brace - brace_position + 1}
        when /\d+/
          return {:quantity => quantifier.to_i, :step => close_brace - brace_position + 1}
        else
          return {:quantity => -1, :step => 0}
        end
      else
        return {:quantity => -1, :step => 0}
      end  
    else
      return {:quantity => -1, :step => 0}
    end
  when '?'
    #handle 0 or 1 occurrence
    return {:quantity => rand(0..1), :step => 1}
  else
    #handle single character, no quantifier
    return {:quantity => 1, :step => 0}
  end
end

def process_metacharacter(metacharacter)
  characters = ''
  rejections = ''

  case metacharacter
      
  #add any character but a space character
  when 'S'
    characters << ('!'..'~').to_a.join
    rejections << ' '
  #add a space character
  when 's'
    characters << ' '
    
  #add any character but a digit
  when 'D'
    characters << (' '..'~').to_a.join
    rejections << ('0'..'9').to_a.join
     
  #add a digit
  when 'd'
    characters << ('0'..'9').to_a.join

  #add a tab
  when 't'
    characters << '\t'
      
  #add a non hex character
  when 'H'
    characters << (' '..'~').to_a.join
    rejections << ('0'..'9').to_a.join
    rejections << ('A'..'F').to_a.join
    
  #add a hex character
  when 'h'
    characters << ('0'..'9').to_a.join 
    characters << ('A'..'F').to_a.join
      
  #add a non word character
  when 'W'
    characters << (' '..'A').to_a.join
    rejections << ('0'..'9').to_a.join 
    rejections << ('A'..'z').to_a.join
     
  #add a word character
  when 'w'
    characters << ('0'..'9').to_a.join
    characters << ('A'..'z').to_a.join
  end
  
  rejections.scan(/./).each do |rejection|
    characters.delete(rejection)
  end

  return characters
end

def increment(code)
  # increment the next code character in the final place of the code string
  last_character = code[-1]
  
  # flag to check previous characters
  upper_increment_flag = 0
  
  index_next_character = @regex_map[-1][:character_set].index(last_character) + 1
  
  if index_next_character == @regex_map[-1][:character_set].length
    index_next_character = 0
	upper_increment_flag = 1
  end
  
  code[-1] = @regex_map[-1][:character_set][index_next_character]
  
  # loop through each character from second last to first, incrementing
  if upper_increment_flag == 1 
	current_index = code.length - 2
	while current_index > -1
	  # if the character is the last in its set
	  if code[current_index] == @regex_map[current_index][:character_set][-1]
        code[current_index] = @regex_map[current_index][:character_set][0]
	  else
	    index_next_character = @regex_map[current_index][:character_set].index(code[current_index]) + 1
	    code[current_index] = @regex_map[current_index][:character_set][index_next_character]
	    break
	  end
	  current_index = current_index - 1
	end
  end
  
  return code
end

#Need to evaluate codes which come under the desired amount
def add_permutations()
      puts @regex_map[-1][:character_set]
	  
	  # If there are codes, increment based on the previous permutation
	  # Check from the last character to the first to see that it has reached the last element in the sequence
	  permutation_index = 0
	  map_element = 0
      total_possibilities = 1
	  
	  #get the number of possibilities within each map n^r
	  while map_element < @regex_map.length
	    total_possibilities *= (@regex_map[map_element][:character_set].length * @regex_map[map_element][:quantifier])
		map_element += 1
	  end
	  
	  current_index = 0
	  first_permutation = ''
	  # create the first permutation
	  while current_index < @regex_map.length
	    current_q = 0
	    while current_q < @regex_map[current_index][:quantifier]
	      first_permutation << @regex_map[current_index][:character_set][0]
		  current_q += 1
		end
	    current_index += 1
	  end
	  
	  @codes << first_permutation

	  current_index = 0
	  final_permutation = ''
	  #create the last permutation
      while current_index < @regex_map.length
	   current_q = 0
		while current_q < @regex_map[current_index][:quantifier]
		  final_permutation << @regex_map[current_index][:character_set][-1]
		  current_q += 1
		end
		current_index += 1
	  end
	  
	  current_index = 0
	  while current_index < @regex_map.length
	    current_q = 0
		while current_q < @regex_map[current_index][:quantifier]
		  puts @regex_map[current_q][:character_set]
		  current_q += 1
		end
		current_index += 1
	  end
	  
	  #while the current permutation is not equal to the final permutation
	  current_permutation = @codes[0]
	  
	  while current_permutation != final_permutation
		current_permutation = increment(current_permutation)
		@codes << current_permutation
	  end
    
end

def add_segment(character_set,quantifier)
  #Only add the main component, not *ed by the quantifier, we check this against the regex
  @regex_map << {character_set: character_set, quantifier: quantifier}
end

def parse_structure(regex)
  #Skip characters based on regex structure
  step = 1

  #Flag for any failures in matching pairs or orders
  structure_valid = 0
  x = 0

  while x < regex.length
    #handle the character
    case regex[x]
    when '[' 
      #find the position of the next ] and get step, if no ], invalid
      close_bracket = regex[x..regex.length].index(']')
      quantity = get_quantifier_value(regex, close_bracket)
      if ! close_bracket.nil?
        step = process_bracket_expression(regex[x+1..y-1], quantity)
      else
        structure_valid = 1
        break
      end
    when '\\'
      if x < (regex.length - 1)
        quantifier_data = parse_quantifier_structure(regex, x+2)
        if quantifier_data[:quantity] > -1
          character_set = process_metacharacter(regex[x+1])
          add_segment(character_set, quantifier_data[:quantity])
          x += 1 + quantifier_data[:step]
        else
          structure_valid = 1
          break
        end
      else
        structure_valid = 1
        break
      end
    else
      quantifier_data = parse_quantifier_structure(regex, x+1) 
      if quantifier_data[:quantity] > -1
        add_segment(regex[x], quantifier_data[:quantity])
        x += quantifier_data[:step]
      else
        structure_valid = 1
        break
      end
    end
      x += 1
  end

  return structure_valid
end

def build_codes(expression)
  @codes = Array.new()
  structure = parse_structure(expression)
  if structure
	add_permutations()
  else
    puts "Regex structure invalid"
  end
end

options = OpenStruct.new
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-a A", Integer,"Amount to generate") do |a|
    options.amount = a
  end
  
  opts.on("-e E", String, "") do |e|
    options.expression = e
  end
  
end.parse!

@amount = options.amount
@regex = options.expression
@regex_map = []
build_codes(options.expression)

   
   