class Product < ApplicationRecord
  belongs_to :shop
  has_many :product_alternatives
end

validates :score, presence: true
