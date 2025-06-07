# frozen_string_literal: true

require_relative "shipping_calculator/version"
require_relative "shipping_calculator/service"
require_relative "shipping_calculator/models/sailing"
require_relative "shipping_calculator/services/route_finder"

require "json"
# rubocop:disable Style/Documentation
module ShippingCalculator
  class Error < StandardError; end
  # Your code goes here...

  def self.run
    puts "Enter origin port:"
    origin = gets.strip

    puts "Enter destination port:"
    destination = gets.strip

    puts "Enter the criteria"
    criteria = gets.strip

    data = JSON.parse(File.read("./response.json"))
    service = ShippingCalculator::Service.new(data)

    result = service.call(origin, destination, criteria)

    puts "\nResult:"
    puts JSON.pretty_generate(result)
  end
end
# rubocop:enable Style/Documentation
