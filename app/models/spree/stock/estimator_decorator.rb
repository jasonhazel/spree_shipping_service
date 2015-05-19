Spree::Stock::Estimator.class_eval do
  def shipping_rates(package)
    if package.only_giftcard?
      ship_method = shipping_methods.find_by(admin_name: 'Digital')
      package.shipping_rates << Spree::ShippingRate.new({
        name: 'Digital',
        cost: 0,
        shipping_method_id: ship_method.id
      })
    else
      shipping_rates = rates(package)
      shipping_methods.each do |ship_method|
        rate = rate_by_shipping_method(shipping_rates, ship_method)
        if rate.nil?
          if ship_method.calculator.type == 'Spree::Calculator::Shipping::PickUp'
            if package.order.ship_address.state.abbr.upcase == ship_method.calculator.preferred_state_code.upcase
              package.shipping_rates << Spree::ShippingRate.new({
                name: ship_method.name,
                cost: 0,
                shipping_method_id: ship_method.id
              })
            end
          end
        else
          unless skip_usps?(package, rate)
            package.shipping_rates << Spree::ShippingRate.new({
              name: rate.desc,
              service_code: rate.service_code,
              cost: rate.negotiated_rate || rate.rate,
              shipping_method_id: ship_method.id
            })
          end
        end
      end
    end
    package.shipping_rates
  end


  private
    def skip_usps?(package, rate)
      package.has_batteries? && rate.service_code =~ /USPS/i
    end

    def digital?(package)

    end


    def shipping_methods
      @shipping_methods ||= Spree::ShippingMethod.all
    end

    def shipping_method(rate)
      shipping_methods.find_by(admin_name: rate.service_code)
    end

    def rate_by_shipping_method(rates, shipping_method)
      rates.select { |r| r.service_code == shipping_method.admin_name }.first
    end

    def prepare_package(package)
      package # until we determine what we actually need
    end

    def api_path(params)
      "http://www.switchboxinc.com.php53-2.dfw1-2.websitetestlink.com/php_shipper/index.php?#{params.to_query}"
    end



    def rates(package)   
      if package.box.nil?
        boxes = Spree::BoxSize.package_fits(package)
        package.box = boxes.first
      end

      address = package.order.shipping_address

      details = {
        address: address.address1,
        address_1: address.address2,
        city: address.city,
        state: address.state.abbr,
        zip: address.zipcode,
        country: address.country.iso,
        length: package.box.length,
        height: package.box.height,
        width: package.box.width,
        weight: package.weight + package.box.weight
      }
      details[:insurance] = package.price if package.order.shipping_insurance

      response = open(api_path(details)).read
      process_response(response, package)
    end 

    def process_response(json, package)
      JSON.parse(json)['rates'].map do |c, rates|
        rates.map do |rate|

          rate_as_object = OpenStruct.new(rate)
          rate_as_object.service_code = "#{c.upcase}-#{rate_as_object.service_code}"
          rate_as_object
        end
      end.flatten
    end
end