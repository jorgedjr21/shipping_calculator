# frozen_string_literal: true

module ShippingCalculator
  # Orchestrates route calculations and returns results for given criteria
  class Service
    attr_reader :sailings, :rates, :exchange_rates, :finder

    def initialize(data)
      @sailings = data["sailings"]
      @rates = data["rates"]
      @exchange_rates = data["exchange_rates"]
      @finder = ShippingCalculator::Services::RouteFinder.new(
        sailings: sailings,
        rates: rates,
        exchange_rates: exchange_rates
      )
    end

    def call(origin, destination, criteria)
      case criteria
      when "cheapest-direct"
        sailing = finder.find_cheapest_direct(origin, destination)
        sailing.map(&:to_h)
      when "cheapest"
        sailing = finder.find_cheapest(origin, destination)
        sailing.map(&:to_h)
      when "fastest"
        sailing = finder.find_fastest(origin, destination)
        sailing.map(&:to_h)
      else
        []
      end
    end
  end
end
