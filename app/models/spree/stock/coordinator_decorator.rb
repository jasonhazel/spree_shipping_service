Spree::Stock::Coordinator.class_eval do
  def estimate_packages(packages)
    estimator = Spree::Stock::Estimator.new(order)

    rates = []

    packages.each do |package|
      estimator.shipping_rates(package).each do |rate|
        rates << rate
      end
      # rates << *estimator.shipping_rates(package)
      package.shipping_rates.each do |rate|
        rate.update_attributes(selected: false)
      end
    end

    if packages.count > 1
      combined_shipping = Spree::Stock::Package.new(Spree::StockLocation.first, packages.first.order)
      combined_shipping.shipping_rates = combine_rates(rates, packages)
      combined_shipping.shipping_rates.first.selected = true
    
      packages.unshift combined_shipping
    end

    packages.first.shipping_rates.each do |rate|
      rate.update_attributes(cost: rate.shipping_method.calculator.compute(packages.first))
    end

    packages
  end

  def combine_rates(rates, packages)
    combined = rates.group_by(&:name).map do |k,v|
      if v.size == packages.count
        Spree::ShippingRate.new(
          cost: v.sum(&:cost),
          name: k
        )
      end
    end

    combined.compact.sort_by(&:cost)
  end


end