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
Shop.destroy_all
puts "Records destroyed"
#NEW SEED
require 'net/http'
require 'uri'
require 'zlib'
require 'stringio'
require 'json'

uri = URI('https://www.quechoisir.org/ajax/carte/circuit-court/get_circuit_court.php')
request = Net::HTTP::Post.new(uri)
request['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:123.0) Gecko/20100101 Firefox/123.0'
request['Accept'] = '*/*'
request['Accept-Language'] = 'fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3'
request['Accept-Encoding'] = 'gzip, deflate, br'
request['Referer'] = 'https://www.quechoisir.org/carte-interactive-circuit-court-n97688/'
request['Content-Type'] = 'multipart/form-data; boundary=---------------------------5906652542480545502450207537'
request['Origin'] = 'https://www.quechoisir.org'
request['DNT'] = '1'
request['Connection'] = 'keep-alive'
request['Cookie'] = 'survey=2; PHPSESSID=2umbho4o2n1tivh7etvqa3k19m'
request['Sec-Fetch-Dest'] = 'empty'
request['Sec-Fetch-Mode'] = 'cors'
request['Sec-Fetch-Site'] = 'same-origin'
request['Sec-GPC'] = '1'
request['TE'] = 'trailers'

body = "-----------------------------5906652542480545502450207537\r\n" \
       "Content-Disposition: form-data; name=\"zipCodeOrCity\"\r\n" \
       "\r\n" \
       "Paris 11e arrondissement 75011\r\n" \
       "-----------------------------5906652542480545502450207537\r\n" \
       "Content-Disposition: form-data; name=\"communeId\"\r\n" \
       "\r\n" \
       "75111\r\n" \
       "-----------------------------5906652542480545502450207537\r\n" \
       "Content-Disposition: form-data; name=\"radius\"\r\n" \
       "\r\n" \
       "5\r\n" \
       "-----------------------------5906652542480545502450207537--\r\n"

request.body = body

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
  http.request(request)
end

case response['Content-Encoding']
when 'gzip'
  sio = StringIO.new(response.body)
  gz = Zlib::GzipReader.new(sio)
  content = gz.read
when 'deflate'
  content = Zlib::Inflate.inflate(response.body)
else
  content = response.body
end

results = JSON.parse(content)

results["circuit_court"]["circuit_court"].each do |shop_data|
  p shop_data
  Shop.create!(
    name: shop_data["magasin"]["nom"],
    description: shop_data["magasin"]["type"],
    opening_hours: shop_data["magasin"]["horaire"],
    address:  shop_data.dig("magasin", "adresse").slice("adresse", "cp", "ville").values.join(', '),
    latitude: shop_data["lat"],
    longitude: shop_data["lon"],
  )
end

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
      eco_score: eco_score, bar_code: "123456789"
    )
    pa.environment = {
      "Changement climatique" => row[:changement_climatique],
      score_unique_ef: row[:score_unique_ef]
    }
    pa.health = {
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


# Mapping of products to their associated pesticides
pesticides_mapping = {
  "Carotte Franprix" => ["Pesticide1", "Pesticide2", "Pesticide3"],
  "Carotte La Main Verte" => ["Pesticide1", "Pesticide2", "Pesticide3"],
  "Patate douce Franprix" => ["Pesticide4", "Pesticide5", "Pesticide6"],
  "Patate douce La Main Verte" => ["Pesticide4", "Pesticide5", "Pesticide6"],
  "Kiwi Franprix" => ["Pesticide7", "Pesticide8", "Pesticide9"],
  "Kiwi La Main Verte" => ["Pesticide7", "Pesticide8", "Pesticide9"]
}



custom_product_1 = Product.new(name: "Carotte")
ProductAlternative.create!(
  product: custom_product_1,
  name: "Carotte Franprix",
  eco_score: worst_product.eco_score,
  environment: worst_product.environment,
  health: worst_product.health,
  bar_code: "123456789"
)
ProductAlternative.create!(
  product: custom_product_1,
  name: "Carotte La Main Verte",
  eco_score: best_product.eco_score,
  environment: best_product.environment,
  health: best_product.health,
  bar_code: "123456789"
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
  environment: worst_product.environment,
  health: worst_product.health,
  bar_code: "123456789"
)
ProductAlternative.create!(
  product: custom_product_2,
  name: "Patate douce La Main Verte",
  eco_score: best_product.eco_score,
  environment: best_product.environment,
  health: best_product.health,
  bar_code: "ABC-abc-1243"
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
  environment: worst_product.environment,
  health: worst_product.health,
  bar_code: "123456789"
)
ProductAlternative.create!(
  product: custom_product_3,
  name: "Kiwi La Main Verte",
  eco_score: best_product.eco_score,
  environment: best_product.environment,
  health: best_product.health,
  bar_code: "ABC-abc-1234"
)

puts "Custom products created"
