class Customer < ActiveRecord::Base
  has_many :customers_shipping_address

  def primary_shipping_address
    self.customers_shipping_address.find_by(primary: true).address
  end
  has_one :customers_billing_addresses
  has_one :billing_address, through: :customers_billing_address, source: :address
end
