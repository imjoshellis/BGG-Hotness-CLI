require_relative './bgg-hotness-cli/scraper.rb'
require_relative './bgg-hotness-cli/game.rb'
require_relative './bgg-hotness-cli/wrap.rb'
require_relative './bgg-hotness-cli/page.rb'
require 'launchy'
require 'tty-prompt'

class BggHotnessCLI
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

  # Runs program by creating empty pages,
  # doing a scrape of the hot list, adding games to pages,
  # and printing the first 10 items on the list.
  def run
    # Create empty pages
    Page.make_pages

    # Scrape list, which creates game instances
    # and adds them to their pages in order.
    Scraper.new("https://www.boardgamegeek.com/xmlapi2/hot?boardgame").game_list
    
    Page.all[0].display_page
  end

  # NOTE: #run must be last so other methods can load.
end