# frozen_string_literal: true

require_relative "../rate_converter"
require_relative "route_calculators/cheapest"
require_relative "route_calculators/direct"

module ShippingCalculator
  module Services
    # Finds sailing routes based on origin, destination, and criteria like cost or speed.
    # Currently supports finding the cheapest direct route.
    class RouteFinder
      attr_reader :rate_map

      def initialize(sailings:, rates:, exchange_rates:)
        @sailings = sailings
        @rate_map = rates.to_h { |r| [r["sailing_code"], r] }
        @converter = RateConverter.new(exchange_rates: exchange_rates)
      end

      def find_cheapest_direct(origin, destination)
        RouteCalculators::Direct
          .new(@sailings, @rate_map, @converter)
          .calculate(origin, destination)
      end

      def find_cheapest(origin, destination)
        RouteCalculators::Cheapest
          .new(@sailings, @rate_map, @converter)
          .calculate(origin, destination)
      end
    end
  end
end
