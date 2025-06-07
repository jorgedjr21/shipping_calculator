# frozen_string_literal: true

require "spec_helper"
require "shipping_calculator/models/sailing"

RSpec.describe ShippingCalculator::Models::Sailing do
  let(:sailing_data) do
    {
      "origin_port" => "CNSHA",
      "destination_port" => "NLRTM",
      "departure_date" => "2022-01-29",
      "arrival_date" => "2022-02-15",
      "sailing_code" => "QRST"
    }
  end

  let(:rate_data) do
    {
      "rate" => "761.96",
      "rate_currency" => "EUR"
    }
  end

  let(:eur_value) { 761.96 }

  subject(:sailing) do
    described_class.new(
      sailing_data: sailing_data,
      rate_data: rate_data,
      eur_rate: eur_value
    )
  end

  it "exposes sailing attributes" do
    expect(sailing.origin_port).to eq "CNSHA"
    expect(sailing.destination_port).to eq "NLRTM"
    expect(sailing.departure_date).to eq "2022-01-29"
    expect(sailing.arrival_date).to eq "2022-02-15"
    expect(sailing.sailing_code).to eq "QRST"
    expect(sailing.rate).to eq "761.96"
    expect(sailing.rate_currency).to eq "EUR"
    expect(sailing.eur_rate).to eq 761.96
  end

  it "returns a formatted hash with to_h" do
    expect(sailing.to_h).to eq(
      {
        origin_port: "CNSHA",
        destination_port: "NLRTM",
        departure_date: "2022-01-29",
        arrival_date: "2022-02-15",
        sailing_code: "QRST",
        rate: "761.96",
        rate_currency: "EUR"
      }
    )
  end
end
