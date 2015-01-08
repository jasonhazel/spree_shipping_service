Spree::Stock::Estimator.class_eval do
  def shipping_rates(package)
    rates(package).each do |rate|
      ship_method = shipping_method(rate)
      unless ship_method.nil?
        package.shipping_rates << Spree::ShippingRate.new({
          name: rate.desc,
          cost: rate.negotiated_rate || rate.rate,
          shipping_method_id: ship_method.id
        })
      end
    end


    package.shipping_rates
  end

  private

    def shipping_methods
      @shipping_methods ||= Spree::ShippingMethod.all
    end

    def shipping_method(rate)
      shipping_methods.select do |sm| 
        sm.name == rate.desc
      end.first
    end


    def prepare_package(package)
      package # until we determine what we actually need
    end

    def rates(package)
      package = prepare_package(package)
      # call API || script || whatever the service ends up being

      # convert hash to openstruct
      fake_json_response.map { |r| OpenStruct.new(r) }
    end 

    # remove this later.
    def fake_json_response
      JSON.parse ('[
        {"desc":"UPS Ground","rate":"12.00","service_code":"03","negotiated_rate":"9.56"},
        {"desc":"UPS 3 Day Select","rate":"23.11","service_code":"12","negotiated_rate":"14.98"},
        {"desc":"UPS 2nd Day Air","rate":"28.41","service_code":"02","negotiated_rate":"16.82"},
        {"desc":"UPS Next Day Air Saver","rate":"62.76","service_code":"13","negotiated_rate":"32.37"},
        {"desc":"UPS Next Day Air Early AM","rate":"99.46","service_code":"14","negotiated_rate":"99.46"},
        {"desc":"UPS Next Day Air","rate":"67.36","service_code":"01","negotiated_rate":"34.92"}
      ]')
    end

end