# SimpleCov::Formatter::Inline

A SimpleCov formatter that outputs missing line and branch coverage inline.

Can be configured to filter to certain files and skip output as needed.

Comes with a rails+rspec integration that:

* filters to only the rspec file and the file of the module being tested.
* skips output if any examples fail
* skips output if no examples were run
* skips output if not all examples within a spec file are run

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add simplecov-inline --github="appbot/simplecov-inline"

## Usage

### Plug the formatter in

``` ruby
SimpleCov.formatter = SimpleCov::Formatter::Inline
```

### Configure rails and rspec

``` ruby
SimpleCov::Inline::Integration.configure_rspec_rails
```

### Manually Filter Files

If you are not using rspec and rails you can manually filter to a set of files.

``` ruby
SimpleCov::Formatter::Inline.config do |config|
  config.files = ['/path/to/your/file.rb']
end
```

### Manually Supress Output

If you are not using rspec and rails you can turn off the formatter with a reason.

``` ruby
SimpleCov::Formatter::Inline.config do |config|
  config.no_output!(reason: 'your reason here')
end
```

## Development

After checking out the repo, run `rake` to run the tests and rubocop. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

If would like to use docker, you can run `docker/rake` to save yourself having to install ruby locally.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/appbot/simplecov-inline. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/appbot/simplecov-inline/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SimpleCov::Formatter::Inline project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/appbot/simplecov-inline/blob/main/CODE_OF_CONDUCT.md).
