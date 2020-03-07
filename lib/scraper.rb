require 'nokogiri'
require 'open-uri'
require 'pry'
require_relative './game.rb'

class Scraper
  def initialize(path)
    @doc = Nokogiri::HTML(open(path))
  end

  def game_list
    @doc.css('item').each do |item|
      name = item.css('name')[0]['value']
      rank = item['rank']
      id = item['id']
      year = item.css('yearpublished')[0]['value']
      Game.new(name, id, year, rank)
    end
  end

  def get_details(game)
    game.description = Nokogiri::HTML.parse(@doc.css('description').text).text
    game.minplayers = @doc.css('minplayers')[0]['value']
    game.maxplayers = @doc.css('maxplayers')[0]['value']
    game.minplaytime = @doc.css('minplaytime')[0]['value'] 
    game.maxplaytime = @doc.css('maxplaytime')[0]['value'] 
    game.minage = @doc.css('minage')[0]['value'] 
    # game.category = @doc.css('link').select{|link| link[0]['type'] == 'boardgamecategory'} 
            # @category = ["cat1","cat2"]
            # @mechanic = ["mech1","mech2"]
            # @publisher = ["pub1", "pub2"]
            # @designer = ["designer1", "designer2"]
    game.url = "https://boardgamegeek.com/boardgame/#{game.id}"
  end
end
