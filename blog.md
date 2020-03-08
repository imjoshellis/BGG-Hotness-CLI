# Creating an interactive CLI with Ruby

## Overview

If you know anything about board games, you know BoardGameGeek.com (BGG) is the best place on the internet to find out what games are trending. However, the website is information-dense, and when you just want to see what games are "hot", there has to be an easier way...

Which is why I put together the bgg-hotness-cli Gem with Ruby.

Well, not exactly. I put together the Gem because it's my first project for the Software Engineering program at Flatiron School. But it was still a fun project, and the BGG API is something I've been wanting to expirment with because I have a side project on the back burner that's going to require heavy usage of the API.

The program itself is fairly simple. It pulls the top 50 hot games from BGG’s API, displays 10
at a time, and lets you see details of any of the games. 

## Putting it all together

The structure of this project morphed a LOT as I built it. The final structure looks something like this:

```txt
├── Gemfile
├── Rakefile
├── bgg-hotness-cli.gemspec
├── bin
│   ├── bgg-hotness-cli
│   └── setup
└── lib
    ├── bgg-hotness-cli
    │   ├── cli.rb
    │   ├── game.rb
    │   ├── helpers.rb
    │   ├── page.rb
    │   └── scraper.rb
    └── bgg-hotness-cli.rb
```

I’ve omitted some GitHub and boilerplate files for clarity. The main point of interest is how lib is organized.

To run the program, you simply `require ‘bgg-hotness-cli’` and call `BggHotnessCLI::CLI.run`. 

### lib/bgg-hotness-cli.rb

This file is simply for requiring all the other files. After trying other patterns, this is a nice and clean way of making sure all the requirements are set in once place.

I used four external requires:

- Nokogiri and open-uri are for parsing the API
- Launchy is used to open a game’s URL if the user selects that option
- TTY-prompt is used to interface with users, more details about that choice in the “Integrating user feedback” section.  

### lib/bgg-hotnesss-cli/cli.rb

This is where the `BggHotnessCLI::CLI` object is defined. It has three class methods. 

`goodbye` gives the user a goodbye message and exits the program. This is called by the other objects when the user chooses an exit option.

`header` resets the terminal and prints a simple header.

`run` initializes the program by telling the Page class to make empty page objects and the Scraper class to create game objects that hold basic data.

### lib/bgg-hotnesss-cli/scraper.rb

The scraper class has two instance methods:

`game_list` pulls all the game items from the API and puts the details of each into an instance of Game.

`get_details` goes to the game’s details on the API and updates the game object’s instance variables with the data.

### lib/bgg-hotnesss-cli/page.rb

Each page object holds 10 games within a specific range. Because the API has 50
items, that means there are 5 page objects: 1-10, 11-20, etc… The page object keeps track of its own start and end ranks as well as its games in an ordered array. 

For example, if you call `Page.all[2].games[0]`, you would get the #30th ranked game because you’re getting the first game of the third page.

The instance method, `display_page` iterates through the games, putting their rank, name, and publication year into an array of hashes called choices for `TTY::Prompter` to parse. The `:name` part of the hash is what TTY::Prompter will display, and `:value` is what will be passed upon selection. The choices array is also set up with an option for going to the next page and quitting.

The user is then given an interactive list (using arrow keys) to select which game to get more details on. 

Finally, there is an if-else section that does an action based off the user’s input.

### lib/bgg-hotnesss-cli/game.rb

The game class has a few methods. Its main one is `display_details`, which does what it sounds like. It first checks to see if its details have been scraped yet and scrapes if necessary. 

It then parses and prints the instance variables along with options for the user, similar to the page method. 

There are a few extra methods for displaying the full description and publisher/designer credits.  I did this because the information was too much when displaying the publisher/designer info by default because some games have a LOT of publishers. Also, and some descriptions on BGG games can be very long, so the only viable option here is to truncate the description and allow the user to view more if they want to.

### lib/bgg-hotnesss-cli/helpers.rb

This file has two helper methods. The first, `wrap`, is a method I found to word-wrap long strings. It worked great out of the box, so I left it alone except for adding the `indent` variable, which allowed me to customize how the information was displayed.

The other method, `print_array`, is a method I wrote from scratch that helps me display info on the game details page. 

One nice feature is that it automatically chooses between a plural or singluar header for a section. For example, some games have many categories and some only have one category. I didn’t want the section header to say “categories” when there was only one category, and this method fixes that.

It also takes an array and adds commas between each item as well as an & symbol before the last item. 

## Integrating user feedback

My only user test for this project was with my wife. She’s good with computers, but had never interacted with a CLI before. 

I originally had the app set up with TTY::Prompter, meaning it used gets to accept a user input. However, my wife’s first assumption when given a list of options was to try to click or use arrow keys to choose an item because this is a common pattern in modern apps.

In order to make the app more user-friendly, I decided to add TTY::Prompter, which allows for the arrow-based interface. 

As a side benefit, the code for choice selection is actually a lot cleaner. I was originally doing some hacky stuff to figure out which game was selected. 

## Final thoughts

It was really fun making this all work. If you want to check out the repo, it’s available on [GitHub.com/imjoshellis/bgg-hotness-cli](https://github.com/imjoshellis/bgg-hotness-cli). There are instructions there for how to use `gem install` to get it on your machine.

_Note: I tried really hard to get a working online demo on repl.it, but I never figured out how to make the arrow key interface function properly. Everything else works, but apparently getting arrow key input doesn’t work the same on there…_