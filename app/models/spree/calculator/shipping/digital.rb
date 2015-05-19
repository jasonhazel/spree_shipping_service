module Spree
  class Calculator::Shipping::Digital < ShippingCalculator
    def self.description
      "Digital Goods"
    end

    def compute_package(package)
      0.0
    end
  end
end