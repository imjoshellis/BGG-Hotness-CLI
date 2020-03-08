# BGG Hotness CLI

## Description

BGG Hotness CLI is a fast command line interface for checking the top 50 hot boardgames of BoardGameGeek.com's API.

It was built by [@imjoshellis](https://github.com/imjoshellis) as a part of Flatiron School's Software Engineering program.

## Installation

Add this line to your application's Gemfile:

```bash
gem "bgg-hotness-cli"

```

And then execute:

```bash
bundle
```

Or if you prefer:

```bash
gem install bgg-hotness-cli
```

## Usage

Run `bin/bgg-hotness-cli` in your terminal for a quickstart.

Or `require 'bgg-hotness-cli` and create run with `BggHotnessCLI::CLI.run`.

For example:

```ruby
irb
require 'bgg-hotness-cli'
BggHotnessCLI::CLI.run
```

Once you're in the interface, use ↑/↓ arrows to navigate between options and press Enter to select your choice.

![screenshot of start page](https://github.com/imjoshellis/BGG-Hotness-CLI/blob/master/img/start-page.jpg 'BGG Hotness CLI Start Page')

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/imjoshellis/bgg-hotness-cli> This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Bgg Hotness CLI project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/imjoshellis/BGG-Hotness-CLI/blob/master/CODE_OF_CONDUCT.md).
