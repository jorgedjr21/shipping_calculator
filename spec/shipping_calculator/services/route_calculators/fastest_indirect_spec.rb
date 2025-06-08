# frozen_string_literal: true

require "spec_helper"
require "shipping_calculator/services/route_calculators/fastest_indirect"

RSpec.describe ShippingCalculator::Services::RouteCalculators::FastestIndirect do
  let(:rates) do
    [
      # Fast chain (2 legs, total duration = 2 days)
      { "sailing_code" => "L1", "rate" => "100", "rate_currency" => "EUR" },
      { "sailing_code" => "L2", "rate" => "100", "rate_currency" => "EUR" },
      # Slow chain (2 legs, total duration = 5 days) cheap
      { "sailing_code" => "H1", "rate" => "1",   "rate_currency" => "EUR" },
      { "sailing_code" => "H2", "rate" => "1",   "rate_currency" => "EUR" }
    ]
  end

  let(:rate_map) { rates.to_h { |r| [r["sailing_code"], r] } }
  let(:exchange_rates) { {} }
  let(:converter) { ShippingCalculator::RateConverter.new(exchange_rates:) }

  let(:sailings) do
    [
      # Fast indirect: A->X->B (1 day + 1 day = 2)
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
      },
      # Slow indirect: A->Y->B (2 days + 3 days = 5)
      {
        "origin_port" => "A",
        "destination_port" => "Y",
        "departure_date" => "2022-01-01",
        "arrival_date" => "2022-01-03",
        "sailing_code" => "H1"
      },
      {
        "origin_port" => "Y",
        "destination_port" => "B",
        "departure_date" => "2022-01-04",
        "arrival_date" => "2022-01-07",
        "sailing_code" => "H2"
      }
    ]
  end

  subject(:calculator) do
    described_class.new(sailings, rate_map, converter)
  end

  describe "#calculate" do
    context "when multiple indirect routes exist" do
      it "selects the two-leg route with the fastest total duration, ignoring price" do
        result = calculator.calculate("A", "B")

        codes = result.map(&:sailing_code)
        expect(codes).to contain_exactly("L1", "L2")

        total_duration = result.sum(&:duration)
        expect(total_duration).to eq(2)
      end
    end

    context "when no indirect route exists" do
      let(:sailings) { [] }

      it "returns an empty array" do
        expect(calculator.calculate("A", "B")).to eq([])
      end
    end

    context "when second leg departs before first arrives" do
      let(:sailings) do
        [
          {
            "origin_port" => "A",
            "destination_port" => "X",
            "departure_date" => "2022-01-01",
            "arrival_date" => "2022-01-05",
            "sailing_code" => "L1"
          },
          {
            "origin_port" => "X",
            "destination_port" => "B",
            "departure_date" => "2022-01-04",
            "arrival_date" => "2022-01-06",
            "sailing_code" => "L2"
          }
        ]
      end

      it "ignores out-of-sequence legs and returns an empty array" do
        expect(calculator.calculate("A", "B")).to eq([])
      end
    end

    context "when calculating n legs route" do
      let(:rates) do
        [
          # Chain1: A1/A2/A3 durations = 2, 3, 1 days
          { "sailing_code" => "A1", "rate" => "10.0", "rate_currency" => "EUR" },
          { "sailing_code" => "A2", "rate" => "10.0", "rate_currency" => "EUR" },
          { "sailing_code" => "A3", "rate" => "10.0", "rate_currency" => "EUR" },
          # Chain2: B1/B2 durations = 2, 5 days
          { "sailing_code" => "B1", "rate" => "10.0", "rate_currency" => "EUR" },
          { "sailing_code" => "B2", "rate" => "10.0", "rate_currency" => "EUR" }
        ]
      end

      let(:rate_map)       { rates.to_h { |r| [r["sailing_code"], r] } }
      let(:exchange_rates) { {} }
      let(:converter)      { ShippingCalculator::RateConverter.new(exchange_rates:) }

      let(:sailings) do
        [
          # Chain1: O → X (2d), X → Y (3d), Y → D (1d)
          {
            "origin_port" => "O",
            "destination_port" => "X",
            "departure_date" => "2022-01-01",
            "arrival_date" => "2022-01-03",
            "sailing_code" => "A1"
          },
          {
            "origin_port" => "X",
            "destination_port" => "Y",
            "departure_date" => "2022-01-04",
            "arrival_date" => "2022-01-07",
            "sailing_code" => "A2"
          },
          {
            "origin_port" => "Y",
            "destination_port" => "D",
            "departure_date" => "2022-01-08",
            "arrival_date" => "2022-01-09",
            "sailing_code" => "A3"
          },
          # Chain2: O → Z (2d), Z → D (5d)
          {
            "origin_port" => "O",
            "destination_port" => "Z",
            "departure_date" => "2022-01-01",
            "arrival_date" => "2022-01-03",
            "sailing_code" => "B1"
          },
          {
            "origin_port" => "Z",
            "destination_port" => "D",
            "departure_date" => "2022-01-04",
            "arrival_date" => "2022-01-09",
            "sailing_code" => "B2"
          }
        ]
      end

      it "selects the fastest chain among all possible indirect paths" do
        result = calculator.calculate("O", "D")
        codes  = result.map(&:sailing_code)

        expect(codes).to eq(%w[A1 A2 A3])
        expect(result.sum(&:duration)).to eq(6)
      end
    end
  end
end
