# frozen_string_literal: true
require 'spec_helper'
require 'shipping_calculator/rate_converter'

RSpec.describe ShippingCalculator::RateConverter do

  let(:exchange_rates) do
    {
      "2022-01-29" => {
        "usd" => 1.1138,
        "jpy" => 130.85
      },
      "2022-01-30" => {
        "usd" => 1.1138,
        "jpy" => 132.97
      },
      "2022-01-31" => {
        "usd" => 1.1156,
        "jpy" => 131.2
      },
      "2022-02-01" => {
        "usd" => 1.126,
        "jpy" => 130.15
      },
      "2022-02-02" => {
        "usd" => 1.1323,
        "jpy" => 133.91
      },
      "2022-02-15" => {
        "usd" => 1.1483,
        "jpy" => 149.93
      },
      "2022-02-16" => {
        "usd" => 1.1482,
        "jpy" =>149.93
      }
    }
  end

  subject(:converter) { described_class.new(exchange_rates: exchange_rates) }

  context "when converting USD to EUR" do
    it 'returns the correct EUR value' do
      result = converter.to_eur("70.96", "USD", "2022-01-29")
      expect(result).to be_within(0.01).of(63.70)
    end
  end

  context "when converting JPY to EUR" do
    it 'returns the correct EUR value' do
      result = converter.to_eur("10500", "JPY", "2022-02-15")
      expect(result).to be_within(0.01).of(70.03)
    end
  end

  context 'when the currency is EUR already' do
    it 'returns the same amount' do
      result = converter.to_eur("456.78", "EUR", "2022-02-16")
      expect(result).to eq(456.78)
    end
  end

  context 'when a unknow currency is used' do
    it 'raises a RateMissing error' do
      expect { converter.to_eur('123', "BTC", "2022-02-16") }.to raise_error(
        ShippingCalculator::RateConverter::RateMissing,
         "Missing exchange rate for BTC, date: 2022-02-16"
      )
    end
  end

  context 'when checking the exchange rate in an unknow date' do
    it 'raises a RateMissing error' do
      expect { converter.to_eur('123', "USD", "2025-02-16") }.to raise_error(
        ShippingCalculator::RateConverter::RateMissing,
         "Missing exchange rate for USD, date: 2025-02-16"
      )
    end
  end
end