module Spree
  module Stock
    Package.class_eval do   
      def price
        contents.map(&:line_item).sum(&:price)
      end



      def has_batteries?
        batteries = contents.select do |c|
          c.variant.product.has_battery
        end

        batteries.count > 0
      end
    end
  end
end