# frozen_string_literal: true

require_relative "base_calculator"

module ShippingCalculator
  module Services
    module RouteCalculators
      # Calculates the cheapest direct sailing between two ports.
      class Direct < BaseCalculator
        def calculate(origin, destination)
          @sailings
            .select { |sailing| sailing["origin_port"] == origin && sailing["destination_port"] == destination }
            .map { |sailing| build_sailing(sailing) }
            .compact
            .min_by(&:eur_rate)
            .then { |sailing| sailing ? [sailing] : [] }
        end
      end
    end
  end
end
