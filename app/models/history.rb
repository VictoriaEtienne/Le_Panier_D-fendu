class History < ApplicationRecord
  attr_accessor :barcode

  belongs_to :user
  belongs_to :product_alternative, optional: true
  belongs_to :scanned_product_alternative, class_name: "ProductAlternative"
  belongs_to :shop, optional: true
end
