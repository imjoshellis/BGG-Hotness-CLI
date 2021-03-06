class BggHotnessCLI::Game
  attr_accessor :page, :description, :minplayers, :maxplayers, :minplaytime, :maxplaytime, :minage, :category, :mechanic, :publisher, :designer, :url
  attr_reader :name, :id, :year, :rank

  # Initialize with as much data as the list API gives for each game
  def initialize(name, id, year, rank) 
    @name = name
    @id = id
    @year = year
    @rank = rank

    # Calculate page index of Page.all[]
    page_index = ((@rank.to_i - 1) / 10).floor
    # Put page into its game
    @page = BggHotnessCLI::Page.all[page_index]
    # Put game into its page
    BggHotnessCLI::Page.all[page_index].games << self
  end

  def header
    # Print header
    BggHotnessCLI::CLI.header
    puts 
    puts "#{@rank}. #{@name} (#{@year})"
  end

    # Get the details from the game's details page via API
  def get_details 

    # If the description is nil, it needs to be scraped. 
    # Otherwise, all data should be in memory, so skip this.
    if @description.nil? 
      BggHotnessCLI::Scraper.new("https://boardgamegeek.com/xmlapi2/thing?id=#{@id}").get_details(self)
    end
  end

  def display_details

    # Variable for indentation string to make it easy to change
    @indent = "· " 
    
    # Print loading message. 
    # This is cleared by separator after load finishes,
    # and generally won't be on the screen for long.
    puts
    puts "Loading details..."
    puts

    # Check to see if details exist, and scrapes if needed
    get_details 
    @back_to_details = false
    
    header

    # 2-4 players • 60-90 minutes • ages 12+
    puts "#{@minplayers}–#{@maxplayers} players • #{@minplaytime}–#{@maxplaytime} minutes • ages #{@minage}+"

    # https://boardgamegeek.com/boardgame/ID
    puts "#{@url}"
    puts

    # Use wrap method to add indentation & word wrap
    puts "DESCRIPTION:"
    puts wrap("#{@description[0..140]}...",@indent) 
    puts

    # Use print_array method to print arrays (with wrap method)
    print_array("categories", "category", @category, @indent) 
    print_array("mechanics", "mechanic", @mechanic, @indent)

    # See what user wants to do next
    details_input
  end

  # Displays full description
  def full_description
    header

    # Use wrap method to add indentation & word wrap
    puts "DESCRIPTION:"
    puts wrap("#{@description}",@indent) 
    puts 

    # See what user wants to do next
    details_input
  end

  # Displays publisher(s) and designer(s)
  def publisher_designer
    header

    # Use print_array method to print arrays (with wrap method)
    print_array("publishers", "publisher", @publisher, @indent)
    print_array("designers", "designer", @designer, @indent)
    puts 

    # See what user wants to do next
    details_input
  end

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
      @page.display_page
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
      Launchy.open(@url)
      @input = @rank # Set input to rank so correct game is chosen
      display_details
    elsif @input == choices[4] && @back_to_details
      # If they choose back to game details, go back to game details
      @back_to_details = false
      display_details
    elsif @input == choices.last
      # If they quit, run "goodbye" method
      BggHotnessCLI::CLI.goodbye
    end
  end

end
