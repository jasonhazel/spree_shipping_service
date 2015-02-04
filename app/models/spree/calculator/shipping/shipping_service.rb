module Spree
  class Calculator::Shipping::ShippingService < ShippingCalculator
    preference :handling_fee, :decimal, default: 0

    def self.description
      "Shipping Service API"
    end

    def compute_package(package)
      rate = package.shipping_rates.select do |rate|
        rate.service_code == shipping_method.admin_name
      end.first

      return 0 if rate.nil?

      new_rate = rate.cost + preferred_handling_fee

      # no negative shipping rates
      new_rate < 0 ? 0 : new_rate
    end

    private
    def shipping_method
      Spree::ShippingMethod.find(self.calculable_id)
    end
  end
end
