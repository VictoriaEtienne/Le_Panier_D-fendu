class ProductAlternative < ApplicationRecord
  belongs_to :product
  has_many :shop_alternatives
  has_many :shops, through: :shop_alternatives
  has_many :histories

  def alternatives
    product.product_alternatives.where.not(id: id)
  end

  def alternative_shops
    # oui, desolé a celui qui arrive par là et qui voit ça, faite comme si de rien n'était
    Shop.where(id: alternatives.map(&:shops).uniq.flatten.map(&:id))
  end
end
