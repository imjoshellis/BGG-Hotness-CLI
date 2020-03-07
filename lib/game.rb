class Game
  attr_accessor :description, :minplayers, :maxplayers, :minplaytime, :maxplaytime, :minage, :category, :mechanic, :publisher, :designer, :url
  attr_reader :name, :id, :year, :rank

  # Initialize with as much data as the list API gives for each game
  def initialize(name, id, year, rank) 
    @name = name
    @id = id
    @year = year
    @rank = rank 
    self.class.all << self # Add each game to SSOT
  end

  @@all = [] # SSOT

  def self.all
      @@all
  end

    # Get the details from the game's details page via API
  def get_details 

    # If the description is nil, it needs to be scraped. 
    # Otherwise, all data should be in memory, so skip this.
    if @description.nil? 
      Scraper.new("https://boardgamegeek.com/xmlapi2/thing?id=#{@id}").get_details(self)
    end

  end

end
