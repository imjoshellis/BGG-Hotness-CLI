require_relative './scraper.rb'
require_relative './game.rb'
require_relative './wrap.rb'
require 'launchy'

class CommandLineInterface

  # Displays welcome message
  def welcome
    puts ""
    puts "Hi, welcome to the BGG Hotness List!"
  end

  # Displays goodbye and ends program
  def goodbye
    puts
    puts "Goodbye!"
    puts
    return
  end

  def separator
    puts 
    puts "• • •"
    puts
  end

  # Displays list of games between @start_rank and @end_rank
  def list_games

    # Print separator
    separator

    # Print list header
    puts " #  | year | title"
    puts "------------------------"

    # Prints each game: 2. | 2020 | Game name
    Game.all.select{|game| game.rank.to_i <= @end_rank && game.rank.to_i >= @start_rank}.each do |game| 
      
      # If the rank is less than 10, add an extra space to make numbers line up
      puts " #{game.rank}. | #{game.year} | #{game.name}" if game.rank.to_i < 10
      puts "#{game.rank}. | #{game.year} | #{game.name}" if game.rank.to_i >= 10
    end
    puts 

    puts "Options:"

    # Check to see if user is at end of list and display appropriate message
    puts @end_rank != 50 ? "→ 0 to see the next 10 games on the list" : "→ 0 to see the start of the list"

    # Give user a range of #s to input based on current list
    puts "→ #{@start_rank}–#{@end_rank} to see a game's details"
    puts "→ Q to quit"

    # Prompt user input
    get_input

    # Parse user input
    if @input == "0"
      # If user inputs 0 for the next part of the list...
      if @end_rank == 50
        # ...if at the end of the list (50), loop to beginning
        @start_rank = 1
        @end_rank = 10
        list_games
      else
        # ...otherwise, add 10 to @start_rank and @end_rank
        # Then call this method again (with new values)
        @start_rank += 10
        @end_rank += 10
        list_games
      end
    elsif @input.to_i <= @end_rank && @input.to_i >= @start_rank
      # If user chooses a number between @start_rank - @end_rank, call the details method
      game_details
    elsif @input.downcase == 'q'
      # If they quit, run "goodbye" method
      goodbye
    else
      # If input doesn't work, run method again with error message.
      @invalid_input = true
      list_games
    end
  end

  # Displays details of a chosen game
  def game_details

    # Variable for indentation string to make it easy to change
    @indent = "· " 

    # Find the game that matches the selected rank
    @game = Game.all.select{|game| game.rank == @input}.first 
    
    # Check to see if details exist, and scrapes if needed
    @game.get_details 
    
    # Print details

    # Print separator
    separator

    # 2. Game Name (2020)
    puts "#{@game.rank}. #{@game.name} (#{@game.year})"

    # 2-4 players • 60-90 minutes • ages 12+
    puts "#{@game.minplayers}–#{@game.maxplayers} players • #{@game.minplaytime}–#{@game.maxplaytime} minutes • ages #{@game.minage}+"

    # https://boardgamegeek.com/boardgame/ID
    puts "#{@game.url}"
    puts

    # Use wrap method to add indentation & word wrap
    puts "DESCRIPTION:"
    puts wrap("#{@game.description[0..140]}...",@indent) 
    puts

    # Use print_array method to print arrays (with wrap method)
    print_array("categories", "category", @game.category) 
    print_array("mechanics", "mechanic", @game.mechanic)
    puts

    # See what user wants to do next
    details_input
  end

  # Displays full description
  def full_description

    # Print separator
    separator

    # Use wrap method to add indentation & word wrap
    puts "DESCRIPTION:"
    puts wrap("#{@game.description}",@indent) 
    puts 

    # See what user wants to do next
    details_input
  end

  # Displays publisher(s) and designer(s)
  def publisher_designer
    
    # Print separator
    separator

    # Use print_array method to print arrays (with wrap method)
    print_array("publishers", "publisher", @game.publisher)
    print_array("designers", "designer", @game.designer)
    puts 

    # See what user wants to do next
    details_input
  end

  # Input loop when in @game's details
  def details_input
    # Prompt user input
    puts "Options:"
    puts "→ 0 to return to the list"
    puts "→ 1 to see full description"
    puts "→ 2 to see publisher & designer"
    puts "→ 3 to open BGG page in your default browser"
    puts "→ Q to quit"

    get_input

    # Parse user input
    if @input == "0" 
      # If they choose 0, return to the list
      list_games
    elsif @input == "1"
      # If they choose 1, print full description
      full_description
    elsif @input == "2"
      # If they choose 2, print publisher and designer
      publisher_designer
    elsif @input == "3"
      # If they choose 3, open URL with launchy
      puts
      puts "Attempting to open URL..."
      puts
      Launchy.open(@game.url)
      game_details
    elsif @input.downcase == "q" 
      # If they quit, run "goodbye" method
      goodbye
    else
      # If input doesn't work, return to details and give error message.
      @invalid_input = true
      game_details
    end
  end

  # Prints array with commas as needed
  def print_array(plural, single, array)
  # Sometimes new games have empty fields.
  # Don't do anything if array is empty.
  if array.size != 0 
    puts array.size > 1 ?  "#{plural.upcase}: " : "#{single.upcase}: "
    
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

      # print the output, truncate if too long
      puts output.size < 120 ? wrap(output, @indent) : wrap("#{output[0..120]}...",@indent)
    end
  end

  # Get user input
  def get_input
    # If @invalid_input is true, display error message & reset @invalid_input
    if @invalid_input == true
      puts "ERROR: Invalid input, please try again" 
      @invalid_input = false
    end

    puts
    puts "Type your choice and press enter:"

    # Get user input
    @input = gets.chomp
  end

  # Runs program by doing a scrape of the hot list,
  # printing welcome message, setting the list to 1-10,
  # and printing the first 10 items on the list.
  def run
    Scraper.new("https://www.boardgamegeek.com/xmlapi2/hot?boardgame").game_list
    @start_rank = 1
    @end_rank = 10
    @invalid_input = false
    @input = ""
    welcome
    list_games
  end

  # NOTE: #run must be last so other methods can load.

end
