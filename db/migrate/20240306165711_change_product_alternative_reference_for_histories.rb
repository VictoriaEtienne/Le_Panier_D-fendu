class ChangeProductAlternativeReferenceForHistories < ActiveRecord::Migration[7.1]
  def change
    change_column :histories, :product_alternative_id, :bigint, null: true
  end
end
