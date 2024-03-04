class User < ApplicationRecord
  has_many :histories
  has_many :product_alternatives, through: :histories
  has_many :shops, through: :histories
end
