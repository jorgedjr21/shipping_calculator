# frozen_string_literal: true

module ShippingCalculator
  # ShippingCalculator::RateConverter is responsible for converting
  # rates from various currencies (e.g., USD, JPY) into EUR using
  # historical exchange rates.
  class RateConverter
    class RateMissing < StandardError; end

    def initialize(exchange_rates:)
      @exchange_rates = exchange_rates
    end

    def to_eur(amount, currency, date)
      return amount.to_f if currency == "EUR"

      exchange_rate = @exchange_rates.dig(date, currency.downcase)

      raise RateMissing, "Missing exchange rate for #{currency}, date: #{date}" unless exchange_rate

      amount.to_f / exchange_rate
    end
  end
end
