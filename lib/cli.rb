require_relative './scraper.rb'
require_relative './game.rb'
require_relative './wrap.rb'
require 'launchy'
require 'tty-prompt'

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
    puts "\e[H\e[2J"
    puts 
    puts "BGG Hotness CLI"
    if @listview 
      # When in list view, print this header
      puts "The top #{@start_rank}–#{@end_rank} hot games on BGG."
      puts
    else
      # When in details view, print this
      puts 
      puts "#{@game.rank}. #{@game.name} (#{@game.year})"
    end
  end

  # Displays list of games between @start_rank and @end_rank
  def list_games

    # Variable for header
    @listview = true

    # Variable for details page
    @back_to_details = false

    # Print separator
    separator

    choices = []

    # First option in array is to see next 10 games
    @end_rank != 50 ? choices << "See the next 10 games on the list" : choices << "(end of list) Start over"
    
    # Put each game into choices
    Game.all.select{|game| game.rank.to_i <= @end_rank && game.rank.to_i >= @start_rank}.each do |game| 
      
      # If the rank is less than 10, add an extra space to make numbers line up
      choices << " #{game.rank}. #{game.name} (#{game.year})" if game.rank.to_i < 10
      choices << "#{game.rank}. #{game.name} (#{game.year})" if game.rank.to_i >= 10
    end

    # Last option is always to quit
    choices << "Quit"

    # Set up prompt
    prompt = TTY::Prompt.new(active_color: :blue)

    # Set up greeting
    greeting = "Select a game to view its details:"

    # Capture input & display prompt
    @input = prompt.select(greeting, choices, per_page: 12, cycle: true)
   
    # Parse user input
    if @input == choices[0]
      # If user selects next part of the list...
      if @end_rank == 50
        # ...if at the end of the list (50), loop to beginning
        @start_rank = 1
        @end_rank = 10
        list_games
      else
        # ...otherwise, add 10 to @start_rank and @end_rank
        # Then call this list_games method again (with new values)
        @start_rank += 10
        @end_rank += 10
        list_games
      end
    elsif @input == choices.last
      # If they quit, run "goodbye" method
      goodbye
    else
      # Otherwise, navigate to game
      game_details
    end
  end

  # Displays details of a chosen game
  def game_details

    # Variable for header
    @listview = false

    # Variable for indentation string to make it easy to change
    @indent = "· " 

    # Find the first game that matches the selected string based off its rank
    @game = Game.all.select{|game| game.rank == @input.split('.')[0].strip}.first 
    
    # Check to see if details exist, and scrapes if needed
    @game.get_details 
    
    # Print details

    # Print separator
    separator

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

    choices = [
      "Return to the list",
      "See full description",
      "See publisher(s) & designer(s)",
      "Open BGG page in your default browser"
    ]
    choices << "Return to game details" if @back_to_details
    choices << "Quit"

    # Set up prompt
    prompt = TTY::Prompt.new(active_color: :blue)

    # Set up greeting
    greeting = "Select an option:"

    # Capture input & display prompt
    @input = prompt.select(greeting, choices, cycle: true)

    # Parse user input
    if @input == choices[0] 
      # If they chose 1st option, return to the list
      list_games
    elsif @input == choices[1]
      # If they choose 2nd option, print full description
      @back_to_details = true
      full_description
    elsif @input == choices[2]
      # If they choose 3rd option, print publisher and designer
      @back_to_details = true
      publisher_designer
    elsif @input == choices[3]
      # If they choose 4th option, open URL with launchy and reset details page
      puts
      puts "Attempting to open URL..."
      puts
      Launchy.open(@game.url)
      @input = @game.rank # Set input to rank so correct game is chosen
      game_details
    elsif @input == choices[4] && @back_to_details
      # If they choose back to game details, go back to game details
      @input = @game.rank # Set input to rank so correct game is chosen
      @back_to_details = false
      game_details
    elsif @input == choices.last
      # If they quit, run "goodbye" method
      goodbye
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

      # print the output with word-wrapping
      puts wrap(output, @indent)
      puts
    end
  end

  # Runs program by doing a scrape of the hot list,
  # printing welcome message, setting the list to 1-10,
  # and printing the first 10 items on the list.
  def run
    Scraper.new("https://www.boardgamegeek.com/xmlapi2/hot?boardgame").game_list
    @start_rank = 1
    @end_rank = 10
    @input = ""
    welcome
    list_games
  end

  # NOTE: #run must be last so other methods can load.

end
