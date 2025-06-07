# frozen_string_literal: true

require "shipping_calculator"
require "pry-byebug"
require "simplecov"
require "simplecov-lcov"
require "undercover"

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
SimpleCov.start do
  add_filter(%r{^/spec/}) # For RSpec
  add_filter(%r{^/test/}) # For Minitest
  enable_coverage(:branch) # Report branch coverage to trigger branch-level undercover warnings
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
