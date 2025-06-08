# frozen_string_literal: true

require_relative "base_calculator"

module ShippingCalculator
  module Services
    module RouteCalculators
      # Calculates the fastest indirect sailing between two ports .
      class FastestIndirect < Indirect
        def calculate(origin, destination)
          routes = build_indirect_routes(origin, destination)
          pick_fastest_routes(routes)
        end

        private

        def pick_fastest_routes(routes)
          fastest = routes.min_by { |legs| legs.sum(&:duration) }
          fastest || []
        end
      end
    end
  end
end
