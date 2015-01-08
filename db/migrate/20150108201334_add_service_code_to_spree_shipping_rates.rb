class AddServiceCodeToSpreeShippingRates < ActiveRecord::Migration
  def change
    add_column :spree_shipping_rates, :service_code, :string
  end
end
