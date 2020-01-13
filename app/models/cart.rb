#A cart can have one or more checkouts downstream of it (although in this app it's not possible to have multiple checkouts per cart)
class Cart < ApplicationRecord
  has_many :checkouts , dependent: :destroy
end
