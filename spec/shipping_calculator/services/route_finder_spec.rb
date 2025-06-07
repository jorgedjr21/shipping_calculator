# frozen_string_literal: true

require "spec_helper"
require "shipping_calculator/services/route_finder"

RSpec.describe ShippingCalculator::Services::RouteFinder do
  let(:sailings) do
    [
      {
        "origin_port" => "CNSHA",
        "destination_port" => "NLRTM",
        "departure_date" => "2022-01-29",
        "arrival_date" => "2022-02-15",
        "sailing_code" => "QRST"
      },
      {
        "origin_port" => "CNSHA",
        "destination_port" => "NLRTM",
        "departure_date" => "2022-01-30",
        "arrival_date" => "2022-03-05",
        "sailing_code" => "MNOP"
      }
    ]
  end

  let(:rates) do
    [
      { "sailing_code" => "QRST", "rate" => "761.96", "rate_currency" => "EUR" },
      { "sailing_code" => "MNOP", "rate" => "456.78", "rate_currency" => "USD" }
    ]
  end

  let(:exchange_rates) do
    {
      "2022-01-29" => { "usd" => 1.1138 },
      "2022-01-30" => { "usd" => 1.1138 }
    }
  end

  subject(:finder) do
    described_class.new(
      sailings: sailings,
      rates: rates,
      exchange_rates: exchange_rates
    )
  end

  describe "#find_cheapest_direct" do
    it "returns the cheapest sailing converted to EUR" do
      result = finder.find_cheapest_direct("CNSHA", "NLRTM")

      expect(result).to be_a(ShippingCalculator::Models::Sailing)
      expect(result.sailing_code).to eq("MNOP")
      expect(result.eur_rate).to be_within(0.01).of(410.10)
    end

    it "returns nil if no direct route matches" do
      result = finder.find_cheapest_direct("CNSHA", "BRSSZ")
      expect(result).to be_nil
    end
  end
end
