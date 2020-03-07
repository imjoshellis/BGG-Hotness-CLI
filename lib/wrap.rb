# via http://www.java2s.com/Code/Ruby/String/WordwrappingLinesofText.htm

def wrap(s, indent, width=78)
  s.gsub(/(.{1,#{width}})(\s+|\Z)/, "#{indent}\\1\n")
end