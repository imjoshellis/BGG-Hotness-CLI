require 'nokogiri'
require 'open-uri'
require 'pry'
require_relative './game.rb'

class Scraper

  # Initialize with an API path to open
  def initialize(path)
    @doc = Nokogiri::HTML(URI.open(path))
  end

  # Get the initial list of games from the hotness list.
  def game_list
    
    # Get the data and create a new instance of 
    # Game for each item in the main list
    @doc.css('item').each do |item|
      name = item.css('name')[0]['value']
      rank = item['rank']
      id = item['id']
      year = item.css('yearpublished')[0]['value']

      # Create a new instance of Game with item data
      Game.new(name, id, year, rank)
    end

  end

  # Get the details from the game's details page via API.
  # This could be done during the initial loop, but it's 
  # done per game request to save inital load time.
  def get_details(game) 

    # HTML.parse is used here to clean up HTML codes like &nbsp; and line breaks
    game.description = Nokogiri::HTML.parse(@doc.css('description').text).text

    # These items are pretty easy to grab
    game.minplayers = @doc.css('minplayers')[0]['value']
    game.maxplayers = @doc.css('maxplayers')[0]['value']
    game.minplaytime = @doc.css('minplaytime')[0]['value'] 
    game.maxplaytime = @doc.css('maxplaytime')[0]['value'] 
    game.minage = @doc.css('minage')[0]['value'] 

    # Pull the various types of item out of <link> into respective arrays
    game.category = @doc.css('link').select{|link| link['type']=="boardgamecategory"}.collect{|link| link['value']}
    game.mechanic = @doc.css('link').select{|link| link['type']=="boardgamemechanic"}.collect{|link| link['value']}
    game.publisher = @doc.css('link').select{|link| link['type']=="boardgamepublisher"}.collect{|link| link['value']}
    game.designer = @doc.css('link').select{|link| link['type']=="boardgamedesigner"}.collect{|link| link['value']}

    # The URL formula isn't via API. It's just boardgamegeek's URL scheme.
    game.url = "https://boardgamegeek.com/boardgame/#{game.id}"
  end
end
