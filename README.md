# SemverCheck

A simple gem containing one class `SemverCheck::Compare` to compare SemVer strings.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add semver_check

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install semver_check

## Usage

The Compare class includes the Comparable module, so all methods from there and in addition != are available.

````ruby
SemverCheck::Compare.new("1.2.3") < SemverCheck::Compare.new("1.2.4") # true
SemverCheck::Compare.new("1.2.3") > SemverCheck::Compare.new("1.2.2") # true
SemverCheck::Compare.new("1.2.3") <= SemverCheck::Compare.new("1.2.3") # true
SemverCheck::Compare.new("1.2.3") >= SemverCheck::Compare.new("1.2.3") # true
# works also with prerelease
SemverCheck::Compare.new("1.2.3-alpha") < SemverCheck::Compare.new("1.2.3-beta") # true
SemverCheck::Compare.new("1.2.3-alpha.2") > SemverCheck::Compare.new("1.2.3-alpha.1") # true
````

You get the idea. If you wanna know more check out the `test/test_compare.rb` file.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/the-pulli/semver_check.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
