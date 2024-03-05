class AddInfosToProductAlternatives < ActiveRecord::Migration[7.1]
  def change
    add_column :product_alternatives, :name, :string
    add_column :product_alternatives, :components, :jsonb
    remove_column :product_alternatives, :caracteristics
    add_column :product_alternatives, :caracteristics, :jsonb
  end
end
