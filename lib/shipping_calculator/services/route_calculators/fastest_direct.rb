# frozen_string_literal: true

module ShippingCalculator
  module Services
    module RouteCalculators
      # Calculates the fastest direct sailing between two ports .
      class FastestDirect < BaseCalculator
        def calculate(origin, destination)
          legs = @sailings
                 .select { |s| s["origin_port"] == origin && s["destination_port"] == destination }
                 .map    { |s| build_sailing(s) }
                 .compact

          minimum_duration = legs.map(&:duration).min
          legs.select { |leg| leg.duration == minimum_duration }
        end
      end
    end
  end
end
