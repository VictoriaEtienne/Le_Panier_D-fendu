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
History.destroy_all
User.destroy_all
ShopAlternative.destroy_all
ProductAlternative.destroy_all
Product.destroy_all
Shop.destroy_all
puts "Records destroyed"
#NEW SEED

user = User.create!(
  email: "test@test.com",
  password: "azerty"
)
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
  p shop_data["magasin"]["nom"]

  s = Shop.new(
    name: shop_data["magasin"]["nom"],
    description: shop_data["magasin"]["type"],
    opening_hours: shop_data["magasin"]["horaire"].to_json,
    address: shop_data.dig("magasin", "adresse").slice("adresse", "cp", "ville").values.join(', '),
    latitude: shop_data["lat"],
    longitude: shop_data["lon"],
  )
  s.save!
end

Shop.create(
  name: "Franprix",
  description: "Supermarché",
  opening_hours: results["circuit_court"]["circuit_court"].first["magasin"]["horaire"].to_json,
  address: "65 Rue Servan, 75011 paris",
)

CSV_PRODUCTS = File.join('db', 'seeds', 'agribalyse_synthese_v1.csv')

counter = 0

puts "Creating products and products alternatives with CSV (this might take a while)..."
CSV.foreach(CSV_PRODUCTS, headers: true, header_converters: :symbol) do |row|
  counter += 1

  product = Product.find_or_create_by(name: row[:code_saison])
  eco_score = row[:score_unique_ef]
  next unless eco_score.match?(/\A[\d\.]+\z/)

  eco_score = eco_score.to_f
  rand(3..6).times do |n|
    # added_value = rand(-1.0..1.0)
    # pa_eco_score = eco_score.to_f + added_value
    pa = ProductAlternative.new(
      product:,
      name: "#{row[:code_saison]} n°#{n + 1}",
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
carotte_product_alternatives = Product.where("name ILIKE ?", "%#{product_element}%").map(&:product_alternatives).flatten
worst_product = carotte_product_alternatives.sort_by(&:eco_score).last
best_product = carotte_product_alternatives.sort_by(&:eco_score).first
# Product.where("name ILIKE ?", "%patate douce%").map do |product|
#   product.product_alternatives
# end.flatten

# Mapping of products to their eco-score

pesticide_associations = {
  "Pesticide1" => "Chlorpyrifos",
  "Pesticide2" => "Glyphosate",
  "Pesticide3" => "Métam-sodium",
  "Pesticide4" => "Thiaclopride",
  "Pesticide5" => "Linuron",
  "Pesticide6" => "Pendiméthaline",
  "Pesticide7" => "Difénoconazole",
  "Pesticide8" => "Azoxystrobine",
  "Pesticide9" => "Pyriméthanil",
  "Pesticide10" => "Cuivre en aspersion",
  "Pesticide11" => "Granulés à l'huile d'oignon",
  "Pesticide12" => "Bacillus amyloliquefaciens",
  "Pesticide13" => "Bicarbonate"
}

pesticides_icons = {
  "Chlorpyrifos" => "insecticide_icon.png",
  "Glyphosate" => "herbicide_icon.png",
  "Métam-sodium" => "fongicide_icon.png",
  "Thiaclopride" => "insecticide_icon_icon.png",
  "Linuron" => "herbicide_icon.png",
  "Pendiméthaline" => "herbicide_icon.png",
  "Difénoconazole" => "fongicide.png",
  "Azoxystrobine" => "fongicide_icon.png",
  "Pyriméthanil" => "fongicide_icon.png",
  "Cuivre en aspersion" => "cuivre_icon.png",
  "Granulés à l'huile d'oignon" => "granule_oignon_icon.png",
  "Bacillus amyloliquefaciens" => "biocontrolant_icon.png",
  "Bicarbonate" => "fongicide_icon.png"
}
pesticides_effects = {
  "Chlorpyrifos" => "Insecticide organophosphoré: perturbations endocriniennes, troubles neurologiques, problèmes respiratoires, irritations cutanées, irritations oculaires, troubles gastro-intestinaux, troubles de la fertilité",
  "Glyphosate" => "Herbicide: possibilité de cancérogénicité (en contact direct ou indirect), irritations cutanées, irritations oculaires, problèmes respiratoires, troubles gastro-intestinaux, allergies (en contact direct ou indirect), perturbations endocriniennes",
  "Métam-sodium" => "Fongicide, herbicide et nématicide: irritations cutanées, irritations oculaires, problèmes respiratoires, troubles neurologiques",
  "Thiaclopride" => "Insecticide néonicotinoïde: irritations cutanées, irritations oculaires, problèmes respiratoires, troubles gastro-intestinaux, troubles neurologiques, troubles de la fertilité",
  "Linuron" => "Herbicide : irritations cutanées, irritations oculaires, problèmes respiratoires, troubles gastro-intestinaux, perturbations endocriniennes, troubles de la fertilité",
  "Pendiméthaline" => "Herbicide : irritations cutanées, irritations oculaires, problèmes respiratoires, troubles gastro-intestinaux, troubles neurologiques",
  "Difénoconazole" => "Fongicide triazole : irritations cutanées, irritations oculaires, problèmes respiratoires, troubles gastro-intestinaux, perturbations endocriniennes, possibles effets sur la fertilité",
  "Azoxystrobine" => "Fongicide strobilurine : irritations cutanées, irritations oculaires, problèmes respiratoires, troubles gastro-intestinaux, perturbations endocriniennes, allergies (en contact direct ou indirect)",
  "Pyriméthanil" => "Fongicide anilinopyrimidine : irritations cutanées, irritations oculaires, problèmes respiratoires, troubles gastro-intestinaux, allergies, troubles neurologiques",
  "Cuivre en aspersion" => "Fongicide et bactéricide: irritations cutanées, irritations oculaires, problèmes respiratoires ",
  "Granulés à l'huile d'oignon" => "Fépulsif, éliciteur, fongicide: allergies",
  "Bacillus amyloliquefaciens" => "Biocontrolant: pas d'effets sur la santé",
  "Bicarbonate" => "fongicide, herbicide, régulateur du pH du sol, répulsif, désinfectant : allergies, irritations cutanées, irritations oculaires, troubles gastro-intestinaux"
}

pesticides_mapping = {
  "Carotte Franprix" => ["Pesticide1", "Pesticide3", "Pesticide4", "Pesticide5", "Pesticide6"],
  "Carotte La Main Verte" => ["Pesticide10", "Pesticide11"],
  # "Carotte La Petite Cagette" => ["Pesticide10", "Pesticide11"],
  # "Carotte La Récolte" => ["Pesticide10", "Pesticide11"],
  # "Carotte Au Bout du Champ" => ["Pesticide10", "Pesticide11"],
  # "Carotte Le Pari Local" => ["Pesticide10", "Pesticide11"],
  # "Carotte Le Producteur Local" => ["Pesticide10", "Pesticide11"],
  # "Carotte Les 400 Coop" => ["Pesticide10", "Pesticide11"],
  # "Carotte La Source" => ["Pesticide10", "Pesticide11"],
  # "Carotte La Cale" => ["Pesticide10", "Pesticide11"],
  # "Carotte La Coopérative De La Goutte d'Or" => ["Pesticide10", "Pesticide11"],
  # "Carotte La Coopérative La Louve" => ["Pesticide10", "Pesticide11"],
  # "Carotte Altervojo" => ["Pesticide10", "Pesticide11"],
  # "Carotte Kelbongoo" => ["Pesticide10", "Pesticide11"],
  # "Carotte Gramme" => ["Pesticide10", "Pesticide11"],
  # "Carotte Marché Sur L'Eau" => ["Pesticide10", "Pesticide11"],
  "Patate douce Franprix" => ["Pesticide1", "Pesticide2", "Pesticide3"],
  "Patate douce La Main Verte" => [],
  "Kiwi Franprix" => ["Pesticide1", "Pesticide3", "Pesticide7", "Pesticide8", "Pesticide9"],
  "Kiwi La Main Verte" => ["Pesticide10", "Pesticide12", "Pesticide13"]
}

custom_product_1 = Product.new(name: "Carotte")

main_verte_carotte = ProductAlternative.create!(
  product: custom_product_1,
  name: "Carotte",
  eco_score: best_product.eco_score,
  environment: best_product.environment,
  health: best_product.health.merge(
    pesticides: pesticides_mapping["Carotte La Main Verte"].map { |p| pesticide_associations[p] },
    pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
  ),
  bar_code: "123456789"
)

carotte_franprix = ProductAlternative.create!(
  product: custom_product_1,
  name: "Carotte",
  eco_score: worst_product.eco_score,
  environment: worst_product.environment,
  health: worst_product.health.merge(
    pesticides: pesticides_mapping["Carotte Franprix"].map { |p| pesticide_associations[p] },
    pesticide_icons: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_icons[pesticide_associations[p]] },
    pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
  ),
  bar_code: "00000017"
)

carotte_horrible = ProductAlternative.create!(
  product: custom_product_1,
  name: "Carotte",
  eco_score: worst_product.eco_score,
  environment: worst_product.environment,
  health: worst_product.health.merge(
    pesticides: pesticides_mapping["Carotte Franprix"].map { |p| pesticide_associations[p] },
    pesticide_icons: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_icons[pesticide_associations[p]] },
    pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
  ),
  bar_code: "99999917"
)

carotte_horrible_two = ProductAlternative.create!(
  product: custom_product_1,
  name: "Carotte",
  eco_score: worst_product.eco_score,
  environment: worst_product.environment,
  health: worst_product.health.merge(
    pesticides: pesticides_mapping["Carotte Franprix"].map { |p| pesticide_associations[p] },
    pesticide_icons: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_icons[pesticide_associations[p]] },
    pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
  ),
  bar_code: "99999917"
)

#START
# ProductAlternative.create!(
#   product: custom_product_1,
#   name: "Carotte La Petite Cagette",
#   eco_score: best_product.eco_score,
#   environment: best_product.environment,
#   health: best_product.health.merge(
#     pesticides: pesticides_mapping["Carotte La Petite Cagette"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "123456781"
# )

# ProductAlternative.create!(
#   product: custom_product_1,
#   name: "Carotte La Récolte",
#   eco_score: best_product.eco_score,
#   environment: best_product.environment,
#   health: best_product.health.merge(
#     pesticides: pesticides_mapping["Carotte La Récolte"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "123456712"
# )

# ProductAlternative.create!(
#   product: custom_product_1,
#   name: "Carotte Au Bout du Champ",
#   eco_score: best_product.eco_score,
#   environment: best_product.environment,
#   health: best_product.health.merge(
#     pesticides: pesticides_mapping["Carotte Au Bout du Champ"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "123456123"
# )

# ProductAlternative.create!(
#   product: custom_product_1,
#   name: "Carotte Le Pari Local",
#   eco_score: best_product.eco_score,
#   environment: best_product.environment,
#   health: best_product.health.merge(
#     pesticides: pesticides_mapping["Carotte Le Pari Local"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "123451234"
# )

# ProductAlternative.create!(
#   product: custom_product_1,
#   name: "Carotte Le Producteur Local",
#   eco_score: best_product.eco_score,
#   environment: best_product.environment,
#   health: best_product.health.merge(
#     pesticides: pesticides_mapping["Carotte Le Producteur Local"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "123456721"
# )

# ProductAlternative.create!(
#   product: custom_product_1,
#   name: "Les 400 Coop",
#   eco_score: best_product.eco_score,
#   environment: best_product.environment,
#   health: best_product.health.merge(
#     pesticides: pesticides_mapping["Carotte Les 400 Coop"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "123456722"
# )

# ProductAlternative.create!(
#   product: custom_product_1,
#   name: "Carotte La Source",
#   eco_score: best_product.eco_score,
#   environment: best_product.environment,
#   health: best_product.health.merge(
#     pesticides: pesticides_mapping["Carotte La Source"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "123456723"
# )

# ProductAlternative.create!(
#   product: custom_product_1,
#   name: "Carotte La Cale",
#   eco_score: best_product.eco_score,
#   environment: best_product.environment,
#   health: best_product.health.merge(
#     pesticides: pesticides_mapping["Carotte La Cale"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "123456724"
# )

# ProductAlternative.create!(
#   product: custom_product_1,
#   name: "Carotte La Coopérative De La Goutte d'Or",
#   eco_score: best_product.eco_score,
#   environment: best_product.environment,
#   health: best_product.health.merge(
#     pesticides: pesticides_mapping["Carotte La Coopérative De La Goutte d'Or"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "123456725"
# )

# ProductAlternative.create!(
#   product: custom_product_1,
#   name: "Carotte La Coopérative La Louve",
#   eco_score: best_product.eco_score,
#   environment: best_product.environment,
#   health: best_product.health.merge(
#     pesticides: pesticides_mapping["Carotte La Coopérative La Louve"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "123456726"
# )

# ProductAlternative.create!(
#   product: custom_product_1,
#   name: "Carotte Altervojo",
#   eco_score: best_product.eco_score,
#   environment: best_product.environment,
#   health: best_product.health.merge(
#     pesticides: pesticides_mapping["Carotte Altervojo"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "123456701"
# )

# ProductAlternative.create!(
#   product: custom_product_1,
#   name: "Carotte Kelbongoo",
#   eco_score: best_product.eco_score,
#   environment: best_product.environment,
#   health: best_product.health.merge(
#     pesticides: pesticides_mapping["Carotte Kelbongoo"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "123456702"
# )

# ProductAlternative.create!(
#   product: custom_product_1,
#   name: "Carotte Gramme",
#   eco_score: best_product.eco_score,
#   environment: best_product.environment,
#   health: best_product.health.merge(
#     pesticides: pesticides_mapping["Carotte Gramme"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "123456703"
# )

# ProductAlternative.create!(
#   product: custom_product_1,
#   name: "Carotte Marché Sur L'Eau",
#   eco_score: best_product.eco_score,
#   environment: best_product.environment,
#   health: best_product.health.merge(
#     pesticides: pesticides_mapping["Carotte Gramme"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "123456704"
# )
# #END

product_element = "patate douce"
patate_douce_product_alternatives = Product.where("name ILIKE ?", "%#{product_element}%").map(&:product_alternatives).flatten
worst_product = patate_douce_product_alternatives.sort_by(&:eco_score).last
best_product = patate_douce_product_alternatives.sort_by(&:eco_score).first
# Product.where("name ILIKE ?", "%patate douce%").map do |product|

custom_product_2 = Product.new(name: "Patate douce")
ProductAlternative.create!(
  product: custom_product_2,
  name: "Patate douce",
  eco_score: worst_product.eco_score,
  environment: worst_product.environment,
  health: worst_product.health.merge(
    pesticides: pesticides_mapping["Patate douce Franprix"].map { |p| pesticide_associations[p] },
    pesticide_effects: pesticides_mapping["Patate douce Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
  ),
  bar_code: "123456789"
)

patate_douce = ProductAlternative.create!(
  product: custom_product_2,
  name: "Patate douce",
  eco_score: best_product.eco_score,
  environment: best_product.environment,
  health: best_product.health.merge(
    pesticides: pesticides_mapping["Patate douce La Main Verte"].map { |p| pesticide_associations[p] },
    pesticide_effects: pesticides_mapping["Patate douce La Main Verte"].map { |p| pesticides_effects[pesticide_associations[p]] },
  ),
  bar_code: "00000000"
)

product_element = "kiwi"
kiwi_product_alternatives = Product.where("name ILIKE ?", "%#{product_element}%").map(&:product_alternatives).flatten
worst_product = kiwi_product_alternatives.sort_by(&:eco_score).last
best_product = kiwi_product_alternatives.sort_by(&:eco_score).first
# Product.where("name ILIKE ?", "%patate douce%").map do |product|

custom_product_3 = Product.new(name: "Kiwi")
kiwi_bad = ProductAlternative.create!(
  product: custom_product_3,
  name: "Kiwi",
  eco_score: worst_product.eco_score,
  environment: worst_product.environment,
  health: worst_product.health.merge(
    pesticides: pesticides_mapping["Kiwi Franprix"].map { |p| pesticide_associations[p] },
    pesticide_effects: pesticides_mapping["Kiwi Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
  ),
  bar_code: "01234567"
)

kiwi = ProductAlternative.create!(
  product: custom_product_3,
  name: "Kiwi",
  eco_score: best_product.eco_score,
  environment: best_product.environment,
  health: best_product.health.merge(
    pesticides: pesticides_mapping["Kiwi La Main Verte"].map { |p| pesticide_associations[p] },
    pesticide_effects: pesticides_mapping["Kiwi La Main Verte"].map { |p| pesticides_effects[pesticide_associations[p]] },
  ),
  bar_code: "00000028"
)

#start
# product_element = "Chou Romanesco"
# chou_romanesco_product_alternatives = Product.where("name ILIKE ?", "%#{product_element}%").map(&:product_alternatives).flatten
# worst_product = chou_romanesco_product_alternatives.sort_by(&:eco_score).last
# best_product = chou_romanesco_product_alternatives.sort_by(&:eco_score).first
# # Product.where("name ILIKE ?", "%chou romanesco%").map do |product|

# custom_product_4 = Product.new(name: "Chou Romanesco")
# chou_romanesco_bad = ProductAlternative.create!(
#   product: custom_product_4,
#   name: "Chou Romanesco",
#   eco_score: worst_product.eco_score,
#   environment: worst_product.environment,
#   health: worst_product.health.merge(
#     pesticides: pesticides_mapping["Chou Romanesco Franprix"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Chou Romanesco Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "01234567"
# )

# chou_romanesco = ProductAlternative.create!(
#   product: custom_product_4,
#   name: "Chou Romanesco",
#   eco_score: best_product.eco_score,
#   environment: best_product.environment,
#   health: best_product.health.merge(
#     pesticides: pesticides_mapping["Chou Romanesco La Main Verte"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Chou Romanesco La Main Verte"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "00000028"
# )

# product_element = "Pomme"
# pomme_product_alternatives = Product.where("name ILIKE ?", "%#{product_element}%").map(&:product_alternatives).flatten
# worst_product = pomme_product_alternatives.sort_by(&:eco_score).last
# best_product = pomme_product_alternatives.sort_by(&:eco_score).first
# # Product.where("name ILIKE ?", "%pomme%").map do |product|

# custom_product_5 = Product.new(name: "Pomme")
# pomme_bad = ProductAlternative.create!(
#   product: custom_product_5,
#   name: "Pomme",
#   eco_score: worst_product.eco_score,
#   environment: worst_product.environment,
#   health: worst_product.health.merge(
#     pesticides: pesticides_mapping["Pomme Leclerc"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Pomme"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "01234567"
# )

# pomme = ProductAlternative.create!(
#   product: custom_product_5,
#   name: "Pomme",
#   eco_score: best_product.eco_score,
#   environment: best_product.environment,
#   health: best_product.health.merge(
#     pesticides: pesticides_mapping["Pomme La Main Verte"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Pomme Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "00000028"
# )

# product_element = "Radis"
# radis_product_alternatives = Product.where("name ILIKE ?", "%#{product_element}%").map(&:product_alternatives).flatten
# worst_product = radis_product_alternatives.sort_by(&:eco_score).last
# best_product = radis_product_alternatives.sort_by(&:eco_score).first
# # Product.where("name ILIKE ?", "%radis%").map do |product|

# custom_product_6 = Product.new(name: "Radis")
# radis_bad = ProductAlternative.create!(
#   product: custom_product_6,
#   name: "Radis",
#   eco_score: worst_product.eco_score,
#   environment: worst_product.environment,
#   health: worst_product.health.merge(
#     pesticides: pesticides_mapping["Radis Leclerc"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Radis"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "01234567"
# )

# radis = ProductAlternative.create!(
#   product: custom_product_6,
#   name: "Radis",
#   eco_score: best_product.eco_score,
#   environment: best_product.environment,
#   health: best_product.health.merge(
#     pesticides: pesticides_mapping["Radis La Main Verte"].map { |p| pesticide_associations[p] },
#     pesticide_effects: pesticides_mapping["Radis Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
#   ),
#   bar_code: "00000028"
# )

# history_entry = History.create!(
#   action: "add_product",
#   product: custom_product_5,
#   user_id: 29
# )
#end

puts "Custom products created"

shop_main_verte = Shop.find_by(name: "LA MAIN VERTE")
shop_miyam = Shop.find_by(name: "MIYAM")
shop_saisonniers = Shop.find_by(name: "LES SAISONNIERS")
#start
# shop_petite_cagette = Shop.find_by(name: "LA PETITE CAGETTE")
shop_recolte = Shop.find_by('name LIKE ?', "%RECOLTE%")
shop_pari_local = Shop.find_by(name: "LE PARI LOCAL")
shop_producteur_local = Shop.find_by(name: "LE PRODUCTEUR LOCAL")
shop_400_coop = Shop.find_by(name: "LES 400 COOP")
shop_source = Shop.find_by('name LIKE ?', "%BERRIE%")
shop_cale = Shop.find_by(name: "LA CALE")
shop_goutte_or = Shop.find_by('name LIKE ?', "%GOUTTE%")
shop_louve = Shop.find_by(name: "COOPÉRATIVE LA LOUVE")
shop_altervojo = Shop.find_by(name: "ALTERVOJO")
shop_kelbongoo = Shop.find_by(name: "KELBONGOO")
shop_gramme = Shop.find_by(name: "GRAMME")
franprix = Shop.find_by(name: "Franprix")
#end
# this is where we are going to attach an image on the model
shop_miyam.photo.attach(
  io: File.open('public/images/Miyam.jpg'),
  filename: 'Miyam.jpg', # use the extension of the attached file here content_type: 'image/jpg' # use the mime type of the attached file here
)
shop_miyam.save!

shop_saisonniers.photo.attach(
  io: File.open('public/images/les_saisonniers.jpg'),
  filename: 'les_saisonniers.jpg', # use the extension of the attached file here content_type: 'image/jpg' # use the mime type of the attached file here
)
shop_saisonniers.save!

shop_400_coop.photo.attach(
  io: File.open('public/images/les_400_coop.jpg'),
  filename: 'les_400_coop.jpg', # use the extension of the attached file here content_type: 'image/jpg' # use the mime type of the attached file here
)
shop_400_coop.save!

shop_producteur_local.photo.attach(
  io: File.open('public/images/le_producteur_local.jpg'),
  filename: 'le_producteur_local.jpg', # use the extension of the attached file here content_type: 'image/jpg' # use the mime type of the attached file here
)
shop_producteur_local.save!

shop_main_verte.photo.attach(
  io: File.open('public/images/la_main_verte.jpg'),
  filename: 'la_main_verte.jpg', # use the extension of the attached file here content_type: 'image/jpg' # use the mime type of the attached file here
)
shop_main_verte.save!

shop_kelbongoo.photo.attach(
  io: File.open('public/images/kelbongoo.jpg'),
  filename: 'kelbongoo.jpg', # use the extension of the attached file here content_type: 'image/jpg' # use the mime type of the attached file here
)
shop_kelbongoo.save!

shop_louve.photo.attach(
  io: File.open('public/images/cooperative_la_louve.jpg'),
  filename: 'cooperative_la_louve.jpg', # use the extension of the attached file here content_type: 'image/jpg' # use the mime type of the attached file here
)
shop_louve.save!

shop_altervojo.photo.attach(
  io: File.open('public/images/altervojo.jpg'),
  filename: 'altervojo.jpg', # use the extension of the attached file here content_type: 'image/jpg' # use the mime type of the attached file here
)
shop_altervojo.save!

# ProductAlternative.all.each do |product|
#   ShopAlternative.create!(
#     product_alternative: product,
#     shop: Shop.all.sample
#   )
# end

# Shop.all.each do |shop|
#   product_alternative = ProductAlternative.all.sample
#   unless ShopAlternative.find_by(product_alternative: product_alternative, shop: shop)
#     ShopAlternative.create!(
#       product_alternative: ProductAlternative.all.sample,
#       shop: shop
#     )
#   end
# end

ShopAlternative.create!(
  product_alternative: patate_douce,
  shop: shop_main_verte
)

ShopAlternative.create!(
  product_alternative: carotte_franprix,
  shop: franprix
)

ShopAlternative.create!(
  product_alternative: main_verte_carotte,
  shop: shop_main_verte
)

ShopAlternative.create!(
  product_alternative: carotte_horrible,
  shop: shop_goutte_or
)

ShopAlternative.create!(
  product_alternative: carotte_horrible_two,
  shop: shop_miyam
)

ShopAlternative.create!(
  product_alternative: carotte_franprix,
  shop: shop_saisonniers
)

#start
ShopAlternative.create!(
  product_alternative: carotte_franprix,
  shop: shop_main_verte
)

ShopAlternative.create!(
  product_alternative: carotte_franprix,
  shop: shop_recolte
)

ShopAlternative.create!(
  product_alternative: carotte_franprix,
  shop: shop_pari_local
)

ShopAlternative.create!(
  product_alternative: carotte_franprix,
  shop: shop_producteur_local
)

ShopAlternative.create!(
  product_alternative: carotte_franprix,
  shop: shop_400_coop
)

ShopAlternative.create!(
  product_alternative: carotte_franprix,
  shop: shop_source
)

ShopAlternative.create!(
  product_alternative: carotte_franprix,
  shop: shop_source
)

ShopAlternative.create!(
  product_alternative: carotte_franprix,
  shop: shop_cale
)

ShopAlternative.create!(
  product_alternative: carotte_franprix,
  shop: shop_goutte_or
)

ShopAlternative.create!(
  product_alternative: carotte_franprix,
  shop: shop_louve
)

ShopAlternative.create!(
  product_alternative: carotte_franprix,
  shop: shop_altervojo
)

ShopAlternative.create!(
  product_alternative: carotte_franprix,
  shop: shop_kelbongoo
)

ShopAlternative.create!(
  product_alternative: kiwi,
  shop: shop_main_verte
)

history = History.new(
  user: user,
  scanned_product_alternative: ProductAlternative.find_by("name ILIKE ?", "kiwi"),
  shop: shop_main_verte,
  lat: 48.8630998,
  lng: 2.3816098
)

history.save!

history= History.new(
  user: user,
  scanned_product_alternative: ProductAlternative.find_by("name ILIKE ?", "patate douce"),
  shop: shop_main_verte,
  lat: 48.8630998,
  lng: 2.3816098
)

history.save!
