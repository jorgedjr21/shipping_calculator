# lib/shipping_calculator/services/route_calculators/cheapest.rb
# frozen_string_literal: true

require_relative "direct"
require_relative "indirect"

module ShippingCalculator
  module Services
    module RouteCalculators
      # Selects the cheapest route by comparing direct and indirect options.
      class Cheapest
        def initialize(sailings, rate_map, converter)
          @direct   = Direct.new(sailings, rate_map, converter)
          @indirect = Indirect.new(sailings, rate_map, converter)
        end

        def calculate(origin, destination)
          direct   = @direct.calculate(origin, destination)
          indirect = @indirect.calculate(origin, destination)
          candidates = [direct, indirect].reject(&:empty?)
          candidates.min_by { |legs| legs.sum(&:eur_rate) } || []
        end
      end
    end
  end
end
