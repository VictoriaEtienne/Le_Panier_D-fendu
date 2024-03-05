class Shop < ApplicationRecord
  has_many :shop_alternatives
  has_many :product_alternatives, through: :shop_alternatives
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?
end

validates :name, presence: true
