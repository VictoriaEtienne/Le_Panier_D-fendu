class RemoveNullConstraintOnShopIdForHistories < ActiveRecord::Migration[7.1]
  def change
    change_column :histories, :shop_id, :bigint, null: true
    add_column :histories, :lat, :float
    add_column :histories, :lng, :float
  end
end
