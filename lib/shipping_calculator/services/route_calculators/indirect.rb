# frozen_string_literal: true

require_relative "base_calculator"

module ShippingCalculator
  module Services
    module RouteCalculators
      # Calculates the cheapest sailing route via a single connection.
      class Indirect < BaseCalculator
        def calculate(origin, destination)
          routes = build_indirect_routes(origin, destination)
          pick_best_route(routes)
        end

        private

        def pick_best_route(routes)
          best = routes.min_by { |legs| legs.sum(&:eur_rate) }
          best || []
        end

        def build_indirect_routes(origin, destination)
          first_legs(origin).flat_map do |leg1|
            second_legs(leg1, destination).map { |leg2| build_pair(leg1, leg2) }.compact
          end
        end

        def first_legs(origin)
          @sailings.select { |s| s["origin_port"] == origin }
        end

        def second_legs(leg1, destination)
          @sailings.select do |leg2|
            leg2["origin_port"] == leg1["destination_port"] &&
              leg2["destination_port"] == destination &&
              valid_dates?(leg1, leg2)
          end
        end

        def valid_dates?(leg1, leg2)
          Date.parse(leg2["departure_date"]) >= Date.parse(leg1["arrival_date"])
        end

        def build_pair(leg1, leg2)
          leg1 = build_sailing(leg1)
          leg2 = build_sailing(leg2)

          leg1 && leg2 ? [leg1, leg2] : nil
        end
      end
    end
  end
end
