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
      { "sailing_code" => "LEG1", "rate" => "50.00",  "rate_currency" => "USD" },
      { "sailing_code" => "LEG2", "rate" => "60.00",  "rate_currency" => "USD" },
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
      result = finder.find_cheapest_direct("CNSHA", "NLRTM").first

      expect(result).to be_a(ShippingCalculator::Models::Sailing)
      expect(result.sailing_code).to eq("MNOP")
      expect(result.eur_rate).to be_within(0.01).of(410.10)
    end

    it "returns empty if no direct route matches" do
      result = finder.find_cheapest_direct("CNSHA", "BRSSZ")
      expect(result).to eq([])
    end
  end

  describe "#find_cheapest" do
    context "when the direct route is the cheapest" do
      let(:sailings) do
        [
          # Direct route A -> B
          {
            "origin_port" => "A",
            "destination_port" => "B",
            "departure_date" => "2022-01-01",
            "arrival_date" => "2022-01-02",
            "sailing_code" => "D1"
          },
          # Indirect route A -> X -> B
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

      let(:rates) do
        [
          { "sailing_code" => "D1", "rate" => "18.0", "rate_currency" => "USD" },
          { "sailing_code" => "L1", "rate" => "10.0", "rate_currency" => "USD" },
          { "sailing_code" => "L2", "rate" => "10.0", "rate_currency" => "USD" }
        ]
      end

      let(:exchange_rates) do
        {
          "2022-01-01" => { "usd" => 2.0 },
          "2022-01-03" => { "usd" => 2.0 }
        }
      end
      it "returns only the direct sailing" do
        result = finder.find_cheapest("A", "B")

        expect(result).to be_an(Array)
        expect(result.size).to eq(1)
        expect(result.first.sailing_code).to eq("D1")
        expect(result.first.eur_rate).to be_within(0.01).of(9.0)
      end
    end

    context "when only indirect route exists" do
      let(:sailings) do
        super().reject { |s| %w[QRST MNOP].include?(s["sailing_code"]) }
      end

      it "returns the cheapest two leg route" do
        result = finder.find_cheapest("CNSHA", "NLRTM")

        codes = result.map(&:sailing_code)
        expect(codes).to contain_exactly("LEG1", "LEG4")
        sum = result.map(&:eur_rate).sum
        expect(sum).to be_within(0.01).of(50.0)
      end
    end

    context "when direct and indirect route  exists" do
      it "chooses the route with the lowest total EUR cost" do
        result = finder.find_cheapest("CNSHA", "NLRTM")

        codes = result.map(&:sailing_code)
        expect(codes).to contain_exactly("LEG1", "LEG4")

        total = result.map(&:eur_rate).sum
        expect(total).to be_within(0.01).of(50.0)
      end
    end

    context "when there is no route" do
      it "must returns empty" do
        expect(finder.find_cheapest("ANY", "THING")).to eq([])
      end
    end

    context "when the second leg departs before the first leg arriving" do
      let(:sailings) do
        [
          # First leg arrives after the second leg departs
          {
            "origin_port" => "A",
            "destination_port" => "X",
            "departure_date" => "2022-01-01",
            "arrival_date" => "2022-01-10",
            "sailing_code" => "LATE1"
          },
          # Second leg departs before the first leg arrives
          {
            "origin_port" => "X",
            "destination_port" => "B",
            "departure_date" => "2022-01-09",
            "arrival_date" => "2022-01-12",
            "sailing_code" => "EARLY2"
          }
        ]
      end

      let(:rates) do
        [
          { "sailing_code" => "LATE1", "rate" => "50.0", "rate_currency" => "USD" },
          { "sailing_code" => "EARLY2", "rate" => "50.0", "rate_currency" => "USD" }
        ]
      end

      let(:exchange_rates) do
        {
          "2022-01-01" => { "usd" => 1.0 },
          "2022-01-09" => { "usd" => 1.0 }
        }
      end
      it "ignores legs that are out of sequence and returns empty" do
        expect(finder.find_cheapest("A", "B")).to eq([])
      end
    end
  end
end
