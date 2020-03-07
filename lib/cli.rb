require_relative './scraper.rb'
require_relative './game.rb'
require_relative './wrap.rb'

class CommandLineInterface
  def welcome
    puts ""
    puts "Hi, welcome to the BGG Hotness List!"
  end

  def game_details(rank,invalid_input=false)
    indent = "· "
    game = Game.all.select{|game| game.rank == rank}.first
    game.get_details
    puts ""
    puts "#{game.rank}. #{game.name} (#{game.year})"
    puts "DESCRIPTION:"
    puts wrap("#{game.description[0..240]}...",indent)
    puts "URL:"
    puts "#{indent}#{game.url}"
    puts "INFO:"
    puts "#{indent}#{game.minplayers}–#{game.maxplayers} players • #{game.minplaytime}–#{game.maxplaytime} minutes • ages #{game.minage}+"
    puts game.category.size > 1 ?  "CATEGORIES: " : "CATEGORY: "
    print "#{indent}" # indent categories
    game.category.each_with_index do |category,idx| 
      print category
      # if there's more than one category and this isn't the last item, add commas
      if category != game.category.last && game.category.size > 1
        # print an & before last item
        if idx == game.category.size - 2 
          print ", & " 
        # otherwise, just print a comma and space
        else 
          print ", " 
        end
      end
    end
    puts
    puts game.mechanic.size > 1 ?  "MECHANICS: " : "MECHANIC: "
    print "#{indent}" # indent categories
    game.mechanic.each_with_index do |mechanic,idx| 
      print mechanic
      # if there's more than one category and this isn't the last item, add commas
      if mechanic != game.mechanic.last && game.mechanic.size > 1
        # print an & before last item
        if idx == game.mechanic.size - 2 
          print ", & " 
        # otherwise, just print a comma and space
        else 
          print ", " 
        end
      end
    end
    puts
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

  def run
    @hotlist =
      Scraper.new("https://www.boardgamegeek.com/xmlapi2/hot?boardgame")
    @hotlist.game_list
    @start_rank = 1
    @end_rank = 10
    welcome
    list_games(false)
  end
end
