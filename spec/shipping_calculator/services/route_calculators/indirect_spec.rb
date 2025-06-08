# frozen_string_literal: true

require "spec_helper"
require "shipping_calculator/services/route_calculators/indirect"

RSpec.describe ShippingCalculator::Services::RouteCalculators::Indirect do
  let(:sailings) do
    [
      # valid cheap route A->X->B
      {
        "origin_port" => "A",
        "destination_port" => "X",
        "departure_date" => "2022-01-01",
        "arrival_date" => "2022-01-03",
        "sailing_code" => "L1"
      },
      {
        "origin_port" => "X",
        "destination_port" => "B",
        "departure_date" => "2022-01-05",
        "arrival_date" => "2022-01-06",
        "sailing_code" => "L2"
      },
      # valid expensive route A->Y->B
      {
        "origin_port" => "A",
        "destination_port" => "Y",
        "departure_date" => "2022-01-01",
        "arrival_date" => "2022-01-02",
        "sailing_code" => "H1"
      },
      {
        "origin_port" => "Y",
        "destination_port" => "B",
        "departure_date" => "2022-01-03",
        "arrival_date" => "2022-01-04",
        "sailing_code" => "H2"
      }
    ]
  end
  let(:rates) do
    [
      { "sailing_code" => "L1", "rate" => "50.0", "rate_currency" => "USD" },
      { "sailing_code" => "L2", "rate" => "60.0", "rate_currency" => "USD" },
      { "sailing_code" => "H1", "rate" => "80.0", "rate_currency" => "EUR" },
      { "sailing_code" => "H2", "rate" => "10.0", "rate_currency" => "EUR" }
    ]
  end
  let(:rate_map) { rates.to_h { |r| [r["sailing_code"], r] } }

  # Rates for H1 H2 not necessary, EUR values already
  let(:exchange_rates) do
    {
      "2022-01-01" => { "usd" => 2.0 },
      "2022-01-05" => { "usd" => 2.0 }
    }
  end

  let(:converter) { ShippingCalculator::RateConverter.new(exchange_rates:) }

  subject(:calculator) do
    described_class.new(
      sailings,
      rate_map,
      converter
    )
  end

  describe "#calculate" do
    context "when is a valid indirect route" do
      it "returns the sailing routes" do
        result = calculator.calculate("A", "B")
        expect(result.map(&:sailing_code)).to eq(%w[L1 L2])

        expect(result.sum(&:eur_rate)).to eq(55.0)
      end
    end

    context "when no indirect route exists" do
      subject(:calculator) do
        described_class.new([], rate_map, converter)
      end

      it "returns an empty array" do
        expect(calculator.calculate("X", "Z")).to eq([])
      end
    end

    context "when second leg departs before first arrives" do
      let(:sailings) do
        [
          {
            "origin_port" => "A",
            "destination_port" => "X",
            "departure_date" => "2022-01-01",
            "arrival_date" => "2022-01-10",
            "sailing_code" => "L1"
          },
          {
            "origin_port" => "X",
            "destination_port" => "B",
            "departure_date" => "2022-01-05",
            "arrival_date" => "2022-01-06",
            "sailing_code" => "L2"
          }
        ]
      end

      subject(:calculator) do
        described_class.new(
          sailings,
          rate_map,
          converter
        )
      end

      it "ignores out-of-sequence legs and returns empty array" do
        expect(calculator.calculate("A", "B")).to eq([])
      end
    end
  end
end
