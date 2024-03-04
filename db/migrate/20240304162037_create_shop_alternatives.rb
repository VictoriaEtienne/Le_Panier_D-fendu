class CreateShopAlternatives < ActiveRecord::Migration[7.1]
  def change
    create_table :shop_alternatives do |t|
      t.references :product_alternative, null: false, foreign_key: true
      t.references :shop, null: false, foreign_key: true
      t.float :price

      t.timestamps
    end
  end
end
