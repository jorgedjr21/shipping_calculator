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

      def find_cheapest(origin, destination)
        direct = find_cheapest_direct(origin, destination)
        direct_legs = direct ? [direct] : []

        indirect_legs = find_cheapest_indirect(origin, destination) || []

        candidates = [direct_legs, indirect_legs].reject(&:empty?)
        candidates.min_by do |legs|
          legs.sum(&:eur_rate)
        end
      end

      def find_cheapest_direct(origin, destination)
        direct_routes = @sailings
                        .select { |s| s["origin_port"] == origin && s["destination_port"] == destination }
                        .map { |s| build_sailing(s) }
                        .compact
        direct_routes.min_by(&:eur_rate)
      end

      private

      def find_cheapest_indirect(origin, destination)
        routes = []
        @sailings.each do |s1|
          next unless s1["origin_port"] == origin

          @sailings.each do |s2|
            next unless s2["origin_port"] == s1["destination_port"]
            next unless s2["destination_port"] == destination

            next if Date.parse(s2["departure_date"]) < Date.parse(s1["arrival_date"])

            leg1 = build_sailing(s1)
            leg2 = build_sailing(s2)

            routes << [leg1, leg2] if s1 && s2
          end

          routes.min_by { |legs| legs.sum(&:eur_rate) }
        end
      end

      def build_rate_map(rates)
        rates.to_h { |rate| [rate["sailing_code"], rate] }
      end

      def build_sailing(sailing_data)
        rate_data = @rate_map[sailing_data["sailing_code"]] or return
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
      end
    end
  end
end
