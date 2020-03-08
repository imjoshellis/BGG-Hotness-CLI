require_relative './scraper.rb'
require_relative './game.rb'
require_relative './wrap.rb'
require_relative './page.rb'
require 'launchy'
require 'tty-prompt'

class CommandLineInterface
  # Displays welcome message
  def welcome
    puts ""
    puts "Hi, welcome to the BGG Hotness List!"
  end

  # Displays goodbye and ends program
  def self.goodbye
    puts
    puts "Goodbye!"
    puts
    return
  end

  def self.header
    puts "\e[H\e[2J"
    puts 
    puts "BGG Hotness CLI"
  end

  # Runs program by doing a scrape of the hot list,
  # printing welcome message, setting the list to 1-10,
  # and printing the first 10 items on the list.
  def run
    # Create empty pages
    Page.make_pages

    # Scrape list, which creates game instances
    # and adds them to their pages in order.
    Scraper.new("https://www.boardgamegeek.com/xmlapi2/hot?boardgame").game_list
    welcome
    
    Page.all[0].display_page
  end

  # NOTE: #run must be last so other methods can load.

end
