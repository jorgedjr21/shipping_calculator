# frozen_string_literal: true

require "spec_helper"
require "shipping_calculator/services/route_calculators/fastest_direct"

RSpec.describe ShippingCalculator::Services::RouteCalculators::FastestDirect do
  let(:sailings) do
    [
      {
        "origin_port" => "A",
        "destination_port" => "B",
        "departure_date" => "2022-01-01",
        "arrival_date" => "2022-01-10",
        "sailing_code" => "SLOW"
      },
      {
        "origin_port" => "A",
        "destination_port" => "B",
        "departure_date" => "2022-01-01",
        "arrival_date" => "2022-01-03",
        "sailing_code" => "FAST"
      }
    ]
  end
  let(:rates) do
    [
      { "sailing_code" => "SLOW", "rate" => "1",  "rate_currency" => "EUR" },
      { "sailing_code" => "FAST", "rate" => "10", "rate_currency" => "EUR" },
      { "sailing_code" => "FAST2", "rate" => "10", "rate_currency" => "EUR" }
    ].to_h { |r| [r["sailing_code"], r] }
  end

  let(:exchange_rates) do
    {
      "2022-01-01" => { "usd" => 1.1138 }
    }
  end

  let(:converter) do
    ShippingCalculator::RateConverter.new(exchange_rates: exchange_rates)
  end

  subject(:calculator) { described_class.new(sailings, rates, converter) }

  it "picks the fastest direct sailing" do
    result = calculator.calculate("A", "B")
    expect(result.map(&:sailing_code)).to eq(["FAST"])
    expect(result.first.duration).to eq(2) # 2022-01-01 -> 2022-01-03
  end

  context "when there is more than one fastest route" do
    let(:sailings) do
      super().push(
        {
          "origin_port" => "A",
          "destination_port" => "B",
          "departure_date" => "2022-01-01",
          "arrival_date" => "2022-01-03",
          "sailing_code" => "FAST2"
        }
      )
    end

    it "picks both sailings" do
      result = calculator.calculate("A", "B")
      expect(result.map(&:sailing_code)).to eq(%w[FAST FAST2])
      expect(result.map(&:duration)).to all(eq(2))
    end
  end
end
