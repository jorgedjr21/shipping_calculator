# frozen_string_literal: true

require_relative "shipping_calculator/version"
require_relative "shipping_calculator/service"

require 'json'
module ShippingCalculator
  class Error < StandardError; end
  # Your code goes here...

  def self.run
    data = JSON.parse(File.read('./response.json'))
    service = ShippingCalculator::Service.new(data)
    service.print_data
  end
end
