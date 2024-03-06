class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable
  has_many :histories
  has_many :product_alternatives, through: :histories
  has_many :shops, through: :histories
end
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

#validates :total_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
