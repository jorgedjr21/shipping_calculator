module ShippingCalculator
  class Service
    attr_reader :data
    def initialize(data)
      @data = data
    end

    def print_data
      p data
    end
  end
end