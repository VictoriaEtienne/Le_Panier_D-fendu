class CreateShops < ActiveRecord::Migration[7.1]
  def change
    create_table :shops do |t|
      t.string :name
      t.string :description
      t.float :price
      t.jsonb :opening_hours
      t.string :address

      t.timestamps
    end
  end
end
