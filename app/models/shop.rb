class Shop < ApplicationRecord
  has_many :shop_alternatives
  has_many :product_alternatives, through: :shop_alternatives
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  before_create :serialize_opening_hours

  private

  def serialize_opening_hours
    JSON.parse(opening_hours) if opening_hours.instance_of?(String)
  end
end
