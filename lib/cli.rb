require_relative '../lib/scraper.rb'
require_relative '../lib/game.rb'

class CommandLineInterface
  def run
    @hotlist =
      Scraper.new("https://www.boardgamegeek.com/xmlapi2/hot?boardgame")
    @hotlist.game_list
    @start_rank = 1
    @end_rank = 10
    welcome
    list_games(false)
  end

  def welcome
    puts ""
    puts "Hi, welcome to the BGG Hotness List!"
  end

  def game_details(rank,invalid_input=false)
    game = Game.all.select{|game| game.rank == rank}.first
    game.get_details
    puts ""
    puts "#{game.name}"
    if game.description.size < 64 
      puts "#{game.description}"
    else
      puts "#{game.description[0..64]}..."
    end
    puts game.url
    puts "Enter 'q' to quit or '0' to go back to the list:"
    puts "ERROR: Invalid input, try again" if invalid_input == true
    input = gets.chomp
    if input == "0"
      list_games(false) 
    elsif input.downcase == "q"
      puts "Goodbye!"
      return
    else
      game_details(rank,true) 
    end
  end

  def list_games(invalid_input=false)
    puts ""
    puts " #  | year | title"
    puts "--------------------------------------"
    Game.all.select{|game| game.rank.to_i <= @end_rank && game.rank.to_i >= @start_rank}.each do |game| 
      puts " #{game.rank}. | #{game.year} | #{game.name}" if game.rank.to_i < 10
      puts "#{game.rank}. | #{game.year} | #{game.name}" if game.rank.to_i >= 10
    end
    puts ""
    puts "Enter a game's # to see its details, '0' to see the next 10 titles, or 'q' to quit:"
    puts "ERROR: Invalid input, try again" if invalid_input == true
    input = gets.chomp
    if input == "0"
      if @end_rank == 50
        @start_rank = 1
        @end_rank = 10
        list_games(false) 
      else
        @start_rank += 10
        @end_rank += 10
        list_games(false) 
      end
    elsif input.to_i <= @end_rank && input.to_i >= @start_rank
      game_details(input)
    elsif input.downcase == 'q'
      puts "Goodbye!"
      return
    else
      list_games(true)
    end

    
      
  end
end
