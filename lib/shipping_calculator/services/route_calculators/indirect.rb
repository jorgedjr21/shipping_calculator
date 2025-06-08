# frozen_string_literal: true

require_relative "base_calculator"

module ShippingCalculator
  module Services
    module RouteCalculators
      # Calculates the cheapest sailing route via a single connection.
      class Indirect < BaseCalculator
        def calculate(origin, destination)
          raw_paths = build_indirect_routes(origin, destination, [])
          routes = raw_paths
                   .map { |path| path.map { |s| build_sailing(s) } }
                   .select(&:all?)
                   .select { |legs| valid_dates?(legs) }

          pick_best_route(routes)
        end

        private

        def pick_best_route(routes)
          best = routes.min_by { |legs| legs.sum(&:eur_rate) }
          best || []
        end

        def build_indirect_routes(current_port, destination, visited_ports)
          return [] if visited_ports.include?(current_port)

          visited = visited_ports + [current_port]
          paths = []

          @sailings.select { |s| s["origin_port"] == current_port }.each do |s|
            if s["destination_port"] == destination
              paths << [s]
            else
              subpaths = build_indirect_routes(s["destination_port"], destination, visited)
              subpaths.each { |sp| paths << ([s] + sp) }
            end
          end

          paths
        end
      end
    end
  end
end
