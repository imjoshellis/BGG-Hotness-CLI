require_relative './scraper.rb'
require_relative './game.rb'
require_relative './wrap.rb'
require 'launchy'
require 'pry'
require 'tty-prompt'

# refactoring cli into classes

# each page is a list of 10 games...
# in total, the app will have 5 pages (50 games)...
class Page
  attr_accessor :start_rank, :end_rank, :games, :page_number
  
  @@all = []

  def self.all 
    @@all
  end

  def initialize(start_rank, end_rank)
    @start_rank = start_rank
    @end_rank = end_rank
    @page_number = end_rank / 10
    @games = []
    self.class.all << self
  end

  # Instance Methods

  def display_page
    # Displays list of games between @start_rank and @end_rank

    # Print header
    CommandLineInterface.header
    puts "The top #{@start_rank}–#{@end_rank} hot games on BGG."
    puts

    choices = []

    # First option in array is to see next 10 games
    if @end_rank != 50 
      choices << {name: "See the next 10 games on the list", value: "next"}
    else
      choices << {name: "(end of list) Start over", value: "next"}
    end
    
    # Put each game into choices
    @games.each do |game|
      # If the rank is less than 10, add an extra space to make numbers line up
      choices << {name: " #{game.rank}. #{game.name} (#{game.year})", value: game} if game.rank.to_i < 10
      choices << {name: "#{game.rank}. #{game.name} (#{game.year})", value: game} if game.rank.to_i >= 10
    end

    # Last option is always to quit
    choices << {name: "Quit", value: "quit"}

    # Set up prompt
    prompt = TTY::Prompt.new(active_color: :blue)

    # Set up greeting
    greeting = "Select a game to view its details:"

    # Capture input (input takes :value from choice[x]) & display prompt
    @input = prompt.select(greeting, choices, per_page: 12, cycle: true)

    # Parse user input
    if @input == "next"
      # If user selects next part of the list...
      if @end_rank == 50
        # ...if at the end of the list (50), display the first page
        Page.all[0].display_page
      else
        # ...otherwise, display the next page
        # this works because the first page is [0] index,
        # but it's page # is 1, meaning this will show
        # the second page (which is at all[1]).
        # TODO: make this less confusing?
        Page.all[@page_number].display_page
      end
    elsif @input == 'quit'
      # If they quit, run "goodbye" method
      CommandLineInterface.goodbye
    else
      # Otherwise, navigate to selected game
      @input.display_details
    end
  
  end

  # Class Methods
  def self.add_game(game)
    # when a game is added, put it into the right page.
    # TODO: This loops EVERY time a game is added... could be refactored 
    self.all.each do |page|
      if game.rank.to_i >= page.start_rank && game.rank.to_i <= page.end_rank
        page.games[(game.rank.to_i - 1) % 10] = game
        game.page = self
      end
    end
  end

  # Create 5 pages of 10 games
  def self.make_pages
    _start_rank = 1   # temp local variable
    _end_rank   = 10  # temp local variable
    5.times do 
      Page.new(_start_rank, _end_rank)
      _start_rank += 10
      _end_rank   += 10
    end
  end

  
end