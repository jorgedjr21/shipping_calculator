# frozen_string_literal: true

require "spec_helper"
require "shipping_calculator/services/route_finder"

RSpec.describe ShippingCalculator::Services::RouteFinder do
  let(:sailings) do
    [
      # Two direct routes
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
      },
      # Two indirect routes
      {
        "origin_port" => "CNSHA",
        "destination_port" => "ESBCN",
        "departure_date" => "2022-02-01",
        "arrival_date" => "2022-02-06",
        "sailing_code" => "LEG1"
      },
      {
        "origin_port" => "ESBCN",
        "destination_port" => "NLRTM",
        "departure_date" => "2022-02-07",
        "arrival_date" => "2022-02-10",
        "sailing_code" => "LEG2"
      },
      # expensive route
      {
        "origin_port" => "CNSHA",
        "destination_port" => "ESBCN",
        "departure_date" => "2022-02-01",
        "arrival_date" => "2022-02-06",
        "sailing_code" => "LEG3"
      },
      {
        "origin_port" => "ESBCN",
        "destination_port" => "NLRTM",
        "departure_date" => "2022-02-07",
        "arrival_date" => "2022-02-10",
        "sailing_code" => "LEG4"
      }
    ]
  end

  let(:rates) do
    [
      { "sailing_code" => "QRST", "rate" => "761.96", "rate_currency" => "EUR" },
      { "sailing_code" => "MNOP", "rate" => "456.78", "rate_currency" => "USD" },
      # LEG1 = 50 USD, LEG2 = 60 USD  → EUR value = (50/1.25)+(60/1.25) = 40+48 = 88
      { "sailing_code" => "LEG1", "rate" => "50.00",  "rate_currency" => "USD" },
      { "sailing_code" => "LEG2", "rate" => "60.00",  "rate_currency" => "USD" },
      # LEG3 = 80 EUR, LEG4 = 10 EUR → total = 90 EUR
      { "sailing_code" => "LEG3", "rate" => "80.00",  "rate_currency" => "EUR" },
      { "sailing_code" => "LEG4", "rate" => "10.00",  "rate_currency" => "EUR" }

    ]
  end

  let(:exchange_rates) do
    {
      "2022-01-29" => { "usd" => 1.1138 },
      "2022-01-30" => { "usd" => 1.1138 },
      "2022-02-01" => { "usd" => 1.25 },
      "2022-02-07" => { "usd" => 1.25 }
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

  describe "#find_cheapest" do
    context "when only indirect route exists" do
      let(:sailings) do
        super().reject { |s| %w[QRST MNOP].include?(s["sailing_code"]) }
      end

      it "returns the cheapest two leg route" do
        result = finder.find_cheapest("CNSHA", "NLRTM")
        binding.pry

        expect(result).to be_an(Array).and have(2).items
      end
    end
  end
end
