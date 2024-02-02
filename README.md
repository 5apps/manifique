[![Build Status](https://drone.kosmos.org/api/badges/5apps/manifique/status.svg)](https://drone.kosmos.org/5apps/manifique)

# Manifique

Manifique fetches metadata of Web applications, like e.g. name, description,
and app icons. It prefers information from Web App Manifest files, and falls
back to parsing HTML if necessary.

## Installation

Add this line to your application's Gemfile:

    gem 'manifique'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install manifique

## Usage

First, initialize a Manifique agent for the web app you want to get metadata
for. Its URL is the only required argument:

```ruby
agent = Manifique::Agent.new(url: "https://kosmos.social")
```

Now you can fetch its metadata:

```ruby
metadata = agent.fetch_metadata
```

### Selecting icons

Let's select an icon that we like:

```ruby
icon = metadata.select_icon(type: "image/png", sizes: "96x96")
```

Or maybe just iOS icons? They're pretty convenient for postprocessing after all.

```ruby
icon = metadata.select_icon(purpose: "apple-touch-icon", sizes: "180x180")
```

_TODO check out the docs for options and behavior._

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the specs once, or `bundle exec guard` to watch all source
files and run their specs automatically.

You can also run `bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/5apps/manifique. Please add specs for any changes or
additions.

## Code of Conduct

Everyone interacting in this project’s codebase, issue trackers, and chat
rooms is expected to follow the [code of
conduct](https://github.com/5apps/manifique/blob/master/CODE_OF_CONDUCT.md).
