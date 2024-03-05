class ChangeEcoScoreDataType < ActiveRecord::Migration[7.1]
  def change
    remove_column :product_alternatives, :eco_score
    add_column :product_alternatives, :eco_score, :float
  end
end
