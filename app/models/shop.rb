class Shop < ApplicationRecord
  has_many :shop_alternatives
  has_many :product_alternatives, through: :shop_alternatives
end

validates :name, presence: true
