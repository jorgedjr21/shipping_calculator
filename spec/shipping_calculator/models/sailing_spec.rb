# spec/shipping_calculator/models/sailing_spec.rb
# frozen_string_literal: true

require "spec_helper"
require "shipping_calculator/models/sailing"
require "date"

RSpec.describe ShippingCalculator::Models::Sailing do
  let(:sailing_data) do
    {
      "origin_port" => "CNSHA",
      "destination_port" => "NLRTM",
      "departure_date" => "2022-01-01",
      "arrival_date" => "2022-01-05",
      "sailing_code" => "QRST"
    }
  end

  let(:rate_data) do
    {
      "rate" => "123.45",
      "rate_currency" => "USD"
    }
  end

  # eur_rate is independent of duration/to_h
  let(:eur_rate) { 100.0 }

  subject(:sailing) do
    described_class.new(
      sailing_data: sailing_data,
      rate_data: rate_data,
      eur_rate: eur_rate
    )
  end

  describe "#duration" do
    it "calculates the number of days between departure and arrival" do
      # 2022-01-05 minus 2022-01-01 = 4 days
      expect(sailing.duration).to eq(4)
    end
  end

  describe "attributes" do
    it "exposes the origin, destination, dates, code, rate and currency" do
      expect(sailing.origin_port).to      eq("CNSHA")
      expect(sailing.destination_port).to eq("NLRTM")
      expect(sailing.departure_date).to   eq("2022-01-01")
      expect(sailing.arrival_date).to     eq("2022-01-05")
      expect(sailing.sailing_code).to     eq("QRST")
      expect(sailing.rate).to             eq("123.45")
      expect(sailing.rate_currency).to    eq("USD")
      expect(sailing.eur_rate).to         eq(100.0)
    end
  end

  describe "#to_h" do
    it "returns a hash with formatted rate and all attributes" do
      expect(sailing.to_h).to eq(
        origin_port: "CNSHA",
        destination_port: "NLRTM",
        departure_date: "2022-01-01",
        arrival_date: "2022-01-05",
        sailing_code: "QRST",
        rate: "123.45",
        rate_currency: "USD"
      )
    end
  end
end
