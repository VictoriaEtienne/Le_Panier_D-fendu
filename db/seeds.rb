require 'csv'

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Destroying records..."
ProductAlternative.destroy_all
Product.destroy_all
puts "Records destroyed"

CSV_PRODUCTS = File.join('db', 'seeds', 'agribalyse_synthese_v1.csv')

counter = 0

puts "Creating products and products aleternatives with CSV (this might take a while)..."
CSV.foreach(CSV_PRODUCTS, headers: true, header_converters: :symbol) do |row|
  counter += 1

  product = Product.find_or_create_by(name: row[:nom_du_produit_en_franais])
  eco_score = row[:score_unique_ef]
  next unless eco_score.match?(/\A[\d\.]+\z/)

  eco_score = eco_score.to_f
  rand(3..6).times do |n|
    # added_value = rand(-1.0..1.0)
    # pa_eco_score = eco_score.to_f + added_value
    pa = ProductAlternative.new(
      product:,
      name: "#{row[:nom_du_produit_en_franais]} n°#{n + 1}",
      eco_score: eco_score
    )
    pa.caracteristics = {
      "Changement climatique" => row[:changement_climatique],
      score_unique_ef: row[:score_unique_ef]
    }
    pa.components = {
      "Changement climatique" => row[:changement_climatique],
      score_unique_ef: row[:score_unique_ef]
    }
    pa.save!
  end
end
puts "Products and products aleternatives with CSV created"

puts "Creating custom products..."
# custom seeds (products && product_alternatives)
product_element = "carotte"
patate_douce_product_alternatives = Product.where("name ILIKE ?", "%#{product_element}%").map(&:product_alternatives).flatten
worst_product = patate_douce_product_alternatives.sort_by(&:eco_score).last
best_product = patate_douce_product_alternatives.sort_by(&:eco_score).first
# Product.where("name ILIKE ?", "%patate douce%").map do |product|
#   product.product_alternatives
# end.flatten

custom_product_1 = Product.new(name: "Carotte")
ProductAlternative.create!(
  product: custom_product_1,
  name: "Carotte Franprix",
  eco_score: worst_product.eco_score,
  caracteristics: worst_product.caracteristics,
  components: worst_product.components
)
ProductAlternative.create!(
  product: custom_product_1,
  name: "Carotte La Main Verte",
  eco_score: best_product.eco_score,
  caracteristics: best_product.caracteristics,
  components: best_product.components
)

product_element = "patate douce"
patate_douce_product_alternatives = Product.where("name ILIKE ?", "%#{product_element}%").map(&:product_alternatives).flatten
worst_product = patate_douce_product_alternatives.sort_by(&:eco_score).last
best_product = patate_douce_product_alternatives.sort_by(&:eco_score).first
# Product.where("name ILIKE ?", "%patate douce%").map do |product|

custom_product_2 = Product.new(name: "Patate douce")
ProductAlternative.create!(
  product: custom_product_2,
  name: "Patate douce Franprix",
  eco_score: worst_product.eco_score,
  caracteristics: worst_product.caracteristics,
  components: worst_product.components
)
ProductAlternative.create!(
  product: custom_product_2,
  name: "Patate douce La Main Verte",
  eco_score: best_product.eco_score,
  caracteristics: best_product.caracteristics,
  components: best_product.components
)

product_element = "kiwi"
patate_douce_product_alternatives = Product.where("name ILIKE ?", "%#{product_element}%").map(&:product_alternatives).flatten
worst_product = patate_douce_product_alternatives.sort_by(&:eco_score).last
best_product = patate_douce_product_alternatives.sort_by(&:eco_score).first
# Product.where("name ILIKE ?", "%patate douce%").map do |product|

custom_product_3 = Product.new(name: "Kiwi")
ProductAlternative.create!(
  product: custom_product_3,
  name: "Kiwi Franprix",
  eco_score: worst_product.eco_score,
  caracteristics: worst_product.caracteristics,
  components: worst_product.components
)
ProductAlternative.create!(
  product: custom_product_3,
  name: "Kiwi La Main Verte",
  eco_score: best_product.eco_score,
  caracteristics: best_product.caracteristics,
  components: best_product.components
)

puts "Custom products created"
