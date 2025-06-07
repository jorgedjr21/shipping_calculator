# frozen_string_literal: true

RSpec.describe ShippingCalculator do
  describe ".run" do
    let(:dummy_data) { { "foo" => "bar" } }
    let(:service_instance) { instance_double(ShippingCalculator::Service) }
    let(:result_array) { [{ "hello" => "world" }] }
    let(:response_json) { '{"foo":"bar"}' }

    before do
      allow(File).to receive(:read).with("./response.json").and_return(response_json)
      allow(JSON).to receive(:parse).with(response_json).and_return(dummy_data)

      allow(ShippingCalculator::Service).to receive(:new).with(dummy_data).and_return(service_instance)
      allow(service_instance).to receive(:call).and_return(result_array)
    end

    context "when called with arguments" do
      it "does not prompt and prints the result JSON" do
        expect(ShippingCalculator).not_to receive(:prompt)
        output = StringIO.new
        $stdout = output

        described_class.run("ORIG", "DEST", "cheapest-direct")

        $stdout = STDOUT
        expected = "\nResult:\n#{JSON.pretty_generate(result_array)}\n"
        expect(output.string).to eq(expected)
      end
    end

    context "when called without arguments" do
      it "prompts for origin, destination, and criteria, then prints result" do
        allow(ShippingCalculator).to receive(:prompt).with("Enter the origin:").and_return("ORIG")
        allow(ShippingCalculator).to receive(:prompt).with("Enter the destination:").and_return("DEST")
        allow(ShippingCalculator).to receive(:prompt).with("Enter the criteria:").and_return("cheapest")

        output = StringIO.new
        $stdout = output

        described_class.run

        $stdout = STDOUT
        expected = "\nResult:\n#{JSON.pretty_generate(result_array)}\n"
        expect(output.string).to eq(expected)
      end
    end
  end
end
