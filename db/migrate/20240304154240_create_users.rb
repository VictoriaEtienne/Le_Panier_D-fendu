class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :username
      t.float :total_score
      t.string :email
      t.string :password

      t.timestamps
    end
    add_reference :histories, :user, foreign_key: true
    add_reference :product_alternatives, :user, foreign_key: true
    add_reference :shops, :user, foreign_key: true
  end
end
