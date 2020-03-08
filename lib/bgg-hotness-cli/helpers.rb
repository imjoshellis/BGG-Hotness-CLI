# via http://www.java2s.com/Code/Ruby/String/WordwrappingLinesofText.htm

def wrap(s, indent, width=78)
  s.gsub(/(.{1,#{width}})(\s+|\Z)/, "#{indent}\\1\n")
end

# Prints array with commas as needed
  def print_array(plural, single, array, indent)
  # Sometimes new games have empty fields.
  # Don't do anything if array is empty.
  if array.size != 0 
    puts array.size > 1 ? "#{plural.upcase}: " : "#{single.upcase}: "
    
    # Initialize variable for holding output string
    output = "" 
      array.each_with_index do |item,idx| 
        output += item

        # if there's more than one item and this isn't the last item, add commas
        if item != array.last && array.size > 1

          # print an & before last item
          if idx == array.size - 2 
            output += ", & " 

          # otherwise, just print a comma and space
          else 
            output += ", " 
          end
        end
      end

      # print the output with word-wrapping
      puts wrap(output, indent)
      puts
    end
  end