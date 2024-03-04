class ProductAlternative < ApplicationRecord
  belongs_to :product
  has_many :shop_alternatives
  has_many :shops, through: :shop_alternatives
  has_many :histories
end
