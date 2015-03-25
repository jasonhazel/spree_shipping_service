class AddShippingInsuranceToSpreeOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :shipping_insurance, :boolean
  end
end
