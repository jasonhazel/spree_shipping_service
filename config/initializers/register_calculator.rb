config = Rails.application.config
config.after_initialize do
  config.spree.calculators.shipping_methods = [
    Spree::Calculator::Shipping::ShippingService, 
    Spree::Calculator::Shipping::PickUp
  ]

  config.spree.calculators.tax_rates << Spree::Calculator::TaxWithShipping
end