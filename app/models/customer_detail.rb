class CustomerDetail < ActiveRecord::Base
  #As our materialized view doesn’t have a field named ID, we need to use this to tell Active Record to use CUSTOMER_ID
  self.primary_key = 'customer_id'
end
