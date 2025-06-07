# frozen_string_literal: true

require "date"
require_relative "base_calculator"

module ShippingCalculator
  module Services
    module RouteCalculators
      # Calculates the cheapest sailing route via a single connection.
      class Indirect < BaseCalculator
        def calculate(origin, destination)
          routes = []

          @sailings.each do |s1|
            next unless s1["origin_port"] == origin

            @sailings.each do |s2|
              next unless s2["origin_port"]      == s1["destination_port"]
              next unless s2["destination_port"] == destination
              next if Date.parse(s2["departure_date"]) < Date.parse(s1["arrival_date"])

              leg1 = build_sailing(s1)
              leg2 = build_sailing(s2)
              routes << [leg1, leg2] if leg1 && leg2
            end
          end

          routes.min_by { |legs| legs.sum(&:eur_rate) } || []
        end
      end
    end
  end
end
