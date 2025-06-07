# frozen_string_literal: true

require_relative "../models/sailing"
require_relative "../rate_converter"

module ShippingCalculator
  module Services
    # Finds sailing routes based on origin, destination, and criteria like cost or speed.
    # Currently supports finding the cheapest direct route.
    class RouteFinder
      attr_reader :rate_map

      def initialize(sailings:, rates:, exchange_rates:)
        @sailings = sailings
        @rate_map = build_rate_map(rates)
        @converter = ShippingCalculator::RateConverter.new(exchange_rates: exchange_rates)
      end

      def find_cheapest_direct(origin, destination)
        direct_routes = @sailings.select do |sailing|
          sailing["origin_port"] == origin && sailing["destination_port"] == destination
        end

        enriched_sailings = enrich_sailings(direct_routes)
        enriched_sailings.min_by(&:eur_rate)
      end

      private

      def build_rate_map(rates)
        rates.to_h { |rate| [rate["sailing_code"], rate] }
      end

      def enrich_sailings(sailings)
        sailings.map do |sailing_data|
          rate_data = @rate_map[sailing_data["sailing_code"]]
          next unless rate_data

          eur_value = @converter.to_eur(
            rate_data["rate"],
            rate_data["rate_currency"],
            sailing_data["departure_date"]
          )

          ShippingCalculator::Models::Sailing.new(
            sailing_data: sailing_data,
            rate_data: rate_data,
            eur_rate: eur_value
          )
        end.compact
      end
    end
  end
end
