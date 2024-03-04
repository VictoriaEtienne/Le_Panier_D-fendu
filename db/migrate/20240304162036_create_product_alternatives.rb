class CreateProductAlternatives < ActiveRecord::Migration[7.1]
  def change
    create_table :product_alternatives do |t|
      t.references :product, null: false, foreign_key: true
      t.string :eco_score
      t.text :caracteristics
      t.float :price
      t.string :bar_code

      t.timestamps
    end
  end
end
