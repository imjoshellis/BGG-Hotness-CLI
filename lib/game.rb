class Game
    attr_reader :name, :id, :year, :rank

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
end
