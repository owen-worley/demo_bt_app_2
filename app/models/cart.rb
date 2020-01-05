class Cart < ApplicationRecord
  has_many :checkouts , dependent: :destroy
  # add " , dependent: :destroy" to the above line?
end
