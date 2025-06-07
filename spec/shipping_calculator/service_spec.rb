# frozen_string_literal: true

require "spec_helper"
require "shipping_calculator/service"

RSpec.describe ShippingCalculator::Service do
  let(:sailings) do
    [
      {
        "origin_port" => "CNSHA",
        "destination_port" => "NLRTM",
        "departure_date" => "2022-02-01",
        "arrival_date" => "2022-03-01",
        "sailing_code" => "ABCD"
      },
      {
        "origin_port" => "CNSHA",
        "destination_port" => "NLRTM",
        "departure_date" => "2022-02-02",
        "arrival_date" => "2022-03-02",
        "sailing_code" => "EFGH"
      },
      {
        "origin_port" => "CNSHA",
        "destination_port" => "NLRTM",
        "departure_date" => "2022-01-31",
        "arrival_date" => "2022-02-28",
        "sailing_code" => "IJKL"
      }
    ]
  end

  let(:rates) do
    [
      {
        "sailing_code" => "ABCD",
        "rate" => "589.30",
        "rate_currency" => "USD"
      },
      {
        "sailing_code" => "EFGH",
        "rate" => "490.32",
        "rate_currency" => "EUR"
      },
      {
        "sailing_code" => "IJKL",
        "rate" => "97453",
        "rate_currency" => "JPY"
      }
    ]
  end

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
        "jpy" => 149.93
      }
    }
  end

  let(:input_data) do
    {
      "sailings" => sailings,
      "rates" => rates,
      "exchange_rates" => exchange_rates
    }
  end

  subject(:service) { described_class.new(input_data) }

  describe "#call" do
    context "with cheapest-direct criteria" do
      it "returns the expected result" do
        result = service.call("CNSHA", "NLRTM", "cheapest-direct")

        expect(result).to be_an(Array)
        expect(result.first[:sailing_code]).to eq("EFGH")
        expect(result.first[:rate_currency]).to eq("EUR")
        expect(result.first[:rate]).to eq("490.32")
      end

      context "when the cheapest route is in USD due to exchange rate" do
        let(:sailings) do
          [
            {
              "origin_port" => "CNSHA",
              "destination_port" => "NLRTM",
              "departure_date" => "2022-02-10",
              "arrival_date" => "2022-03-01",
              "sailing_code" => "USD_WIN"
            },
            {
              "origin_port" => "CNSHA",
              "destination_port" => "NLRTM",
              "departure_date" => "2022-02-10",
              "arrival_date" => "2022-03-02",
              "sailing_code" => "EUR_LOSS"
            }
          ]
        end

        let(:rates) do
          [
            {
              "sailing_code" => "USD_WIN",
              "rate" => "100.00",
              "rate_currency" => "USD"
            },
            {
              "sailing_code" => "EUR_LOSS",
              "rate" => "85.00",
              "rate_currency" => "EUR"
            }
          ]
        end

        let(:exchange_rates) do
          {
            "2022-02-10" => { "usd" => 1.25 }
          }
        end

        it "returns the USD sailing as the cheapest after conversion" do
          result = service.call("CNSHA", "NLRTM", "cheapest-direct")

          expect(result).to be_an(Array)
          expect(result.first[:sailing_code]).to eq("USD_WIN")
          expect(result.first[:rate_currency]).to eq("USD")
          expect(result.first[:rate]).to eq("100.00")
        end
      end
    end

    context "when no matching sailing exists" do
      it "returns an empty array" do
        result = service.call("CNSHA", "BRSSZ", "cheapest-direct")
        expect(result).to eq([])
      end
    end

    context "with unsupported criteria" do
      it "returns an empty array" do
        result = service.call("CNSHA", "NLRTM", "cheapest")
        expect(result).to eq([])
      end
    end
  end
end
