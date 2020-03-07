class Game
    attr_reader :name, :id, :year, :rank
    attr_accessor :description, :minplayers, :maxplayers, :minplaytime, :maxplaytime, :minage, :category, :mechanic, :publisher, :designer, :url

    def initialize(name, id, year, rank)
        @name = name
        @id = id
        @year = year
        @rank = rank
        self.class.all << self
    end

    @@all = []

    def self.all
        @@all
    end

    def get_details
        if @description.nil? # If the description is nil, it needs to be scraped. Otherwise, all data should be in memory, so skip this.
            Scraper.new("https://boardgamegeek.com/xmlapi2/thing?id=#{@id}").get_details(self)
        end
    end
end
