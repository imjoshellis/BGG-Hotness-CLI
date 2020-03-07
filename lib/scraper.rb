require "nokogiri"

class Scraper
  def initialize(path)
    @doc = Nokogiri::HTML()
  end
end
