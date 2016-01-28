# Tokenex [![Build Status](https://travis-ci.org/cliffom/tokenex-gem.svg?branch=master)](https://travis-ci.org/cliffom/tokenex-gem) [![Gem Version](https://badge.fury.io/rb/tokenex.svg)](https://badge.fury.io/rb/tokenex)

A convenient Ruby wrapper for the TokenEx API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tokenex'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tokenex

## Usage

### Tokenization

Let's start with a simple tokenization and detokenization of a credit card record:

```ruby
tokenex = Tokenex::Environment.new(api_base_url, token_ex_id, api_key)
token = tokenex.token_from_ccnum(4242424242424242)
ccnum = tokenex.detokenize(token)
is_valid_token = tokenex.validate_token(token)
tokenex.delete_token(token)
arbitrary_data = "This is my string with 3 numbers less than 10"
token = tokenex.tokenize(arbitrary_data)
arbitrary_data = tokenex.detokenize(token)
tokenex.delete_token(token)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cliffom/tokenex-gem.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

