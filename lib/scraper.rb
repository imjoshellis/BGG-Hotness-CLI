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
end
