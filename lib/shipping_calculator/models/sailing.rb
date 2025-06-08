# frozen_string_literal: true

module ShippingCalculator
  module Models
    # Represents a sailing with port information, dates, rate and converted EUR value.
    # Used to encapsulate enriched sailing data for route evaluation.
    class Sailing
      attr_reader :origin_port, :destination_port, :departure_date,
                  :arrival_date, :sailing_code, :rate, :rate_currency,
                  :eur_rate

      def initialize(sailing_data:, rate_data:, eur_rate:)
        @origin_port = sailing_data["origin_port"]
        @destination_port = sailing_data["destination_port"]
        @departure_date   = sailing_data["departure_date"]
        @arrival_date     = sailing_data["arrival_date"]
        @sailing_code     = sailing_data["sailing_code"]
        @rate             = rate_data["rate"]
        @rate_currency    = rate_data["rate_currency"]
        @eur_rate         = eur_rate
      end

      def duration
        (Date.parse(arrival_date) - Date.parse(departure_date)).to_i
      end

      def to_h
        {
          origin_port: origin_port,
          destination_port: destination_port,
          departure_date: departure_date,
          arrival_date: arrival_date,
          sailing_code: sailing_code,
          rate: format("%.2f", rate.to_f),
          rate_currency: rate_currency
        }
      end
    end
  end
end
