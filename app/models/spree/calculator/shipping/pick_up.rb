module Spree
  class Calculator::Shipping::PickUp < ShippingCalculator
    preference :handling_fee, :decimal, default: 0

    def self.description
      "Pick Up"
    end

    def compute_package(package)
      preferred_handling_fee
    end
  end
end