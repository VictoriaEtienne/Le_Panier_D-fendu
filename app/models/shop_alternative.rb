class ShopAlternative < ApplicationRecord
  belongs_to :alternative
  belongs_to :shop
end

validates :score, presence: true
