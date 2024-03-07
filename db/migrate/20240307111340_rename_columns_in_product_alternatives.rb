class RenameColumnsInProductAlternatives < ActiveRecord::Migration[7.1]
  def change
    rename_column :product_alternatives, :components, :health
    rename_column :product_alternatives, :caracteristics, :environment
  end
end
