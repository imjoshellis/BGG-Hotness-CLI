require_relative './scraper.rb'
require_relative './game.rb'
require_relative './wrap.rb'

class CommandLineInterface
  def welcome
    puts ""
    puts "Hi, welcome to the BGG Hotness List!"
  end

  def game_details(rank,invalid_input=false)
    indent = "· " # variable for indentation string to make it easy to change
    game = Game.all.select{|game| game.rank == rank}.first # find the game whos rank matches the selected rank
    game.get_details # this method checks to see if details exist, and scrapes details if needed
    puts ""
    puts "#{game.rank}. #{game.name} (#{game.year})"
    puts "#{game.minplayers}–#{game.maxplayers} players • #{game.minplaytime}–#{game.maxplaytime} minutes • ages #{game.minage}+"
    puts "#{game.url}"
    puts
    puts "DESCRIPTION:"
    puts wrap("#{game.description[0..180]}...",indent) # use wrap function to add indentation & word wrap
    puts
    # use print_array method to print arrays
    print_array("categories", "category", indent, game.category) 
    print_array("mechanics", "mechanic", indent, game.mechanic)
    print_array("publishers", "publisher", indent, game.publisher)
    print_array("designers", "designer", indent, game.designer)
    puts
    puts "→ Enter 0 to return to the list"
    puts "→ Enter Q to quit"
    puts "ERROR: Invalid input, please try again" if invalid_input == true
    input = gets.chomp
    if input == "0" # If they choose 0, return to the list
      list_games(false) 
    elsif input.downcase == "q" # If they quit, run "goodbye" method
      goodbye
    else
      game_details(rank,true) # If input doesn't work, run method again with error message.
    end
  end

  def list_games(invalid_input=false)
    puts ""
    puts " #  | year | title"
    puts "--------------------------------------"
    Game.all.select{|game| game.rank.to_i <= @end_rank && game.rank.to_i >= @start_rank}.each do |game| 
      puts " #{game.rank}. | #{game.year} | #{game.name}" if game.rank.to_i < 10
      puts "#{game.rank}. | #{game.year} | #{game.name}" if game.rank.to_i >= 10
    end
    puts 
    puts "→ Enter # to see a game's details"
    puts "→ Enter 0 to see the next 10 titles"
    puts "→ Enter Q to quit"
    puts "ERROR: Invalid input, please try again" if invalid_input == true
    input = gets.chomp
    if input == "0"
      if @end_rank == 50
        @start_rank = 1
        @end_rank = 10
        list_games(false) 
      else
        @start_rank += 10
        @end_rank += 10
        list_games(false) 
      end
    elsif input.to_i <= @end_rank && input.to_i >= @start_rank
      game_details(input)
    elsif input.downcase == 'q'
      goodbye
    else
      list_games(true) # If input doesn't work, run method again with error message.
    end
  end

  def goodbye
    puts
    puts "Goodbye!"
    puts
    return
  end

  def print_array(plural, single, indent, array)
  if array.size != 0 # sometimes new games have empty fields
    puts array.size > 1 ?  "#{plural.upcase}: " : "#{single.upcase}: "
    output = "" # variable for holding output string
    
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
      # print the output, truncate if too long
      puts output.size < 120 ? wrap(output, indent) : wrap("#{output[0..120]}...",indent)
    end
  end

  def run
    @hotlist =
      Scraper.new("https://www.boardgamegeek.com/xmlapi2/hot?boardgame")
    @hotlist.game_list
    @start_rank = 1
    @end_rank = 10
    welcome
    list_games(false)
  end
end
