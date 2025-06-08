# frozen_string_literal: true

require_relative "base_calculator"

module ShippingCalculator
  module Services
    module RouteCalculators
      # Calculates the fastest indirect sailing between two ports .
      class FastestIndirect < Indirect
        def calculate(origin, destination)
          raw_paths = build_indirect_routes(origin, destination, [])
          routes = raw_paths
                   .map { |path| path.map { |s| build_sailing(s) } }
                   .select(&:all?)
                   .select { |legs| valid_dates?(legs) }
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
