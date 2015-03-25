Spree::Order.class_eval do
  insert_checkout_step :insurance, :after => :address
end