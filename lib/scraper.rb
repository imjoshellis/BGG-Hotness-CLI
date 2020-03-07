require 'nokogiri'
require 'open-uri'

class Scraper
  def initialize(path)
    @doc = Nokogiri.HTML(open(path))
  end
end
