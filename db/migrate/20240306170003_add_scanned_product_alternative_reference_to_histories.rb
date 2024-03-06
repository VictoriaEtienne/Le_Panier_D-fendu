class AddScannedProductAlternativeReferenceToHistories < ActiveRecord::Migration[7.1]
  def change
    add_reference :histories, :scanned_product_alternative, null: false, foreign_key: { to_table: :product_alternatives }
  end
end
