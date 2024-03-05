class ProductAlternative < ApplicationRecord
  belongs_to :product
  has_many :shop_alternatives
  has_many :shops, through: :shop_alternatives
  has_many :histories

  # def eco_score_letter
  #   case eco_score
  #   when -100..-2 then "F"
  #   when -100..-2 then "F"
  # end
end
