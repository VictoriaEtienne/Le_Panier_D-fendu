class History < ApplicationRecord
  belongs_to :user
  belongs_to :product_alternative
  belongs_to :shop
end
