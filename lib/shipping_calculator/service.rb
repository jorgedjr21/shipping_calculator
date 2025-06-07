# frozen_string_literal: true

module ShippingCalculator
  class Service
    attr_reader :sailings, :rates, :exchange_rates

    def initialize(data)
      @sailings = data["sailings"]
      @rates = data["rates"]
      @exchange_rates = data["exchange_rates"]
    end

    def call(origin, destination, criteria)
      finder = ShippingCalculator::Services::RouteFinder.new(
        sailings: @sailings,
        rates: @rates,
        exchange_rates: @exchange_rates
      )

      case criteria
      when "cheapest-direct"
        sailing = finder.find_cheapest_direct(origin, destination)
        sailing ? [sailing.to_h] : []
      else
        []
      end
    end
  end
end
