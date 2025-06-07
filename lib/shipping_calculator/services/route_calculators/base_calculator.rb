# frozen_string_literal: true

require_relative "../../models/sailing"

module ShippingCalculator
  module Services
    module RouteCalculators
      # Defines the interface for a route calculation strategy.
      class BaseCalculator
        def initialize(sailings, rate_map, converter)
          @sailings = sailings
          @rate_map = rate_map
          @converter = converter
        end

        def calculate(origin, destination)
          raise NotImplementedError
        end

        protected

        def build_sailing(sailing_data)
          rate_data = @rate_map[sailing_data["sailing_code"]] || return
          eur_value = @converter.to_eur(
            rate_data["rate"],
            rate_data["rate_currency"],
            sailing_data["departure_date"]
          )
          Models::Sailing.new(
            sailing_data: sailing_data,
            rate_data: rate_data,
            eur_rate: eur_value
          )
        end
      end
    end
  end
end
