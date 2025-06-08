# frozen_string_literal: true

require "spec_helper"
require "shipping_calculator/services/route_calculators/fastest"

RSpec.describe ShippingCalculator::Services::RouteCalculators::Fastest do
  let(:rates) do
    [
      # dummy rates; currency conversion not relevant for duration
      { "sailing_code" => "DIR",  "rate" => "0.0", "rate_currency" => "EUR" },
      { "sailing_code" => "FAST", "rate" => "0.0", "rate_currency" => "EUR" },
      { "sailing_code" => "L1",   "rate" => "0.0", "rate_currency" => "EUR" },
      { "sailing_code" => "L2",   "rate" => "0.0", "rate_currency" => "EUR" }
    ]
  end

  let(:rate_map)       { rates.to_h { |r| [r["sailing_code"], r] } }
  let(:exchange_rates) { {} }
  let(:converter)      { ShippingCalculator::RateConverter.new(exchange_rates:) }

  subject(:calculator) do
    described_class.new(sailings, rate_map, converter)
  end
  describe "#calculate" do
    context "when no routes exist" do
      let(:sailings) { [] }

      it "returns an empty array" do
        expect(calculator.calculate("A", "B")).to eq([])
      end
    end

    context "when only direct routes exist" do
      let(:sailings) do
        [
          {
            "origin_port" => "A",
            "destination_port" => "B",
            "departure_date" => "2022-01-01",
            "arrival_date" => "2022-01-05",
            "sailing_code" => "DIR"
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

      it "selects the single fastest direct sailing" do
        result = calculator.calculate("A", "B")
        codes  = result.map(&:sailing_code)

        expect(codes).to contain_exactly("FAST")
        expect(result.first.duration).to eq(2)
      end
    end

    context "when only indirect routes exist" do
      let(:sailings) do
        [
          {
            "origin_port" => "A",
            "destination_port" => "X",
            "departure_date" => "2022-01-01",
            "arrival_date" => "2022-01-02",
            "sailing_code" => "L1"
          },
          {
            "origin_port" => "X",
            "destination_port" => "B",
            "departure_date" => "2022-01-03",
            "arrival_date" => "2022-01-06",
            "sailing_code" => "L2"
          }
        ]
      end

      it "returns the indirect two-leg route" do
        result = calculator.calculate("A", "B")
        codes  = result.map(&:sailing_code)

        expect(codes).to contain_exactly("L1", "L2")
        expect(result.sum(&:duration)).to eq(4)
      end
    end

    context "when both direct and indirect routes exist" do
      let(:sailings) do
        [
          # direct slow: 5 days
          {
            "origin_port" => "A",
            "destination_port" => "B",
            "departure_date" => "2022-01-01",
            "arrival_date" => "2022-01-06",
            "sailing_code" => "DIR"
          },
          # indirect fast: 1 + 1 = 2 days
          {
            "origin_port" => "A",
            "destination_port" => "X",
            "departure_date" => "2022-01-01",
            "arrival_date" => "2022-01-02",
            "sailing_code" => "L1"
          },
          {
            "origin_port" => "X",
            "destination_port" => "B",
            "departure_date" => "2022-01-03",
            "arrival_date" => "2022-01-04",
            "sailing_code" => "L2"
          }
        ]
      end

      it "chooses the indirect route when it is faster" do
        result = calculator.calculate("A", "B")
        expect(result.map(&:sailing_code)).to contain_exactly("L1", "L2")
        expect(result.sum(&:duration)).to eq(2)
      end

      it "falls back to direct when direct becomes fastest" do
        # adjust direct to be quicker: now 1 day
        sailings[0]["arrival_date"] = "2022-01-02"
        result = calculator.calculate("A", "B")
        expect(result.map(&:sailing_code)).to contain_exactly("DIR")
        expect(result.first.duration).to eq(1)
      end
    end
  end
end
