class Spree::CheckoutController 
  before_action :handle_shipping_insurance, only: [ :update ] 

  private
  def handle_shipping_insurance
    params[:order] = { shipping_insurance: false } if params[:order].nil?
  end

end