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

  def self.run(origin = nil, destination = nil, criteria = nil)
    origin ||= prompt("Enter the origin:")
    destination ||= prompt("Enter the destination:")
    criteria ||= prompt("Enter the criteria:")

    data = JSON.parse(File.read("./response.json"))
    service = ShippingCalculator::Service.new(data)

    result = service.call(origin, destination, criteria)

    puts "\nResult:"
    puts JSON.pretty_generate(result)
  end

  def self.prompt(message)
    print "#{message} "
    gets.strip
  end
end
# rubocop:enable Style/Documentation
