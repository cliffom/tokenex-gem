# Tokenex [![Build Status](https://travis-ci.org/RadPad/tokenex-gem.svg?branch=master)](https://travis-ci.org/RadPad/tokenex-gem) [![Gem Version](https://badge.fury.io/rb/tokenex.svg)](https://badge.fury.io/rb/tokenex)

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

#### Initialize your TokenEx object

The examples below require you first instantiate a new TokenEx object

```ruby
tokenex = Tokenex::Environment.new(api_base_url, token_ex_id, api_key)
```

#### Tokenize a credit card number
```ruby
token = tokenex.token_from_ccnum(4242424242424242)
```

#### Tokenize arbitrary data
```ruby
token = tokenex.tokenize("This is random data containing 3 numbers less than 10")
```

#### Detokenize a token
```ruby
token = tokenex.token_from_ccnum(4242424242424242)
data = tokenex.detokenize(token)
```

#### Validate a token
```ruby
token = tokenex.token_from_ccnum(4242424242424242)
token_is_valid = tokenex.validate_token(token)
```

#### Delete a token
```ruby
token = tokenex.token_from_ccnum(4242424242424242)
tokenex.delete_token(token)
```


#### Errors and References

Each action call will return a reference ID that can be used to lookup a call in
the TokenEx dashboard. Unsuccessful calls will also return an error describing
the problem. Each can be accessed via:
```ruby
tokenex.error
tokenex.reference_number
```

## Development

Before proceeding, make sure the following environment variables are set (they are required for running the specs):
```
TOKENEX_API_BASE_URL=https://test-api.tokenex.com/TokenServices.svc/REST/
TOKENEX_ID=<YOUR TOKENEX_ID>
TOKENEX_API_KEY=<YOUR TOKENEX_API_KEY>
```

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/radpad/tokenex-gem.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
