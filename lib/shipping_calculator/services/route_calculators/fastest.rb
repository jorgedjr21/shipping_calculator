# lib/shipping_calculator/services/route_calculators/cheapest.rb
# frozen_string_literal: true

require_relative "fastest_direct"
require_relative "fastest_indirect"

module ShippingCalculator
  module Services
    module RouteCalculators
      # Selects the fastest route by comparing direct and indirect options.
      class Fastest
        def initialize(sailings, rate_map, converter)
          @direct = FastestDirect.new(sailings, rate_map, converter)
          @indirect = FastestIndirect.new(sailings, rate_map, converter)
        end

        def calculate(origin, destination)
          direct_legs = @direct.calculate(origin, destination)
          indirect_legs = @indirect.calculate(origin, destination)

          candidates = [direct_legs, indirect_legs].reject(&:empty?)
          fastest = candidates.min_by { |legs| legs.sum(&:duration) }
          fastest || []
        end
      end
    end
  end
end
