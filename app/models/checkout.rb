#Checkouts nested within Carts, to represent that a checkout is downstream of a cart in this flow
class Checkout < ApplicationRecord
  belongs_to :cart
end
