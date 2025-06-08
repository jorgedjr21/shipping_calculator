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

        def build_pair(leg1, leg2)
          leg1 = build_sailing(leg1)
          leg2 = build_sailing(leg2)

          leg1 && leg2 ? [leg1, leg2] : nil
        end
      end
    end
  end
end
