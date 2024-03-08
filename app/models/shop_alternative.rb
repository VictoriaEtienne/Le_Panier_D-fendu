class ShopAlternative < ApplicationRecord
  belongs_to :product_alternative
  belongs_to :shop
end
