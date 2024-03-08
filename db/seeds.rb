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

puts "Creating products and products alternatives with CSV (this might take a while)..."
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
carotte_product_alternatives = Product.where("name ILIKE ?", "%#{product_element}%").map(&:product_alternatives).flatten
worst_product = carotte_product_alternatives.sort_by(&:eco_score).last
best_product = carotte_product_alternatives.sort_by(&:eco_score).first
# Product.where("name ILIKE ?", "%patate douce%").map do |product|
#   product.product_alternatives
# end.flatten

# Mapping of products to their eco-score

eco_score_element_details = [
  "Émissions de gaz à effet de serre (CO2)",
  "Destruction de la couche d'ozone",
  "Émissions de particules fines",
  "Oxydation photochimique",
  "Acidification",
  "Radioactivité",
  "Épuisement des ressources en eau",
  "Pollution de l'eau douce",
  "Épuisement des ressources non renouvelables",
  "Eutrophisation (terrestre, eau douce & marine)",
  "Utilisation des terres",
  "Toxicités (eau douce & humaine)",
  "Perte de biodiversité",
  "Épuisement des ressources minérales"
]

eco_score_element_effect = {
  "Émissions de gaz à effet de serre (CO2)" => "Correspond à la modification du climat, affectant l'écosystème global (exprimé en équivalent CO2)",
  "Destruction de la couche d'ozone" => "Son appauvrissement augmente l'exposition de l'ensemble des êtres vivants à des radiations négatives (cancérigènes en particulier)",
  "Émissions de particules fines" => "Les particules fines pénètrent dans les organismes, notamment via les poumons. Elles ont un effet sur la santé humaine",
  "Oxydation photochimique" => "Correspond à une dégradation de la qualité de l'air, principalement via la formation de brouillard de basse altitude nommé smog. Il a des conséquences néfastes sur la santé.",
  "Acidification" => "Résulte d'émissions chimiques dans l'atmosphère qui se redéposent dans les écosystèmes. Cette problématique est connue en particulier via le phénomène des pluies acides",
  "Radioactivité" => "Correspond aux effets de la radioactivité. Cet impact correspond aux déchets radioactifs résultants de la production de l'électricité nucléaire",
  "Épuisement des ressources en eau" => "Correspond à la consommation d'eau et son épuisement dans certaines régions. Cette catégorie tient compte de la rareté (cela a plus d’impact de consommer un litre d'eau au Maroc qu'en Bretagne)",
  "Pollution de l'eau douce" => "Correspond à la présence de micro-organismes, de substances chimiques dans l'eau. Elle peut concerner les cours d’eau, les nappes d’eau, les eaux saumatres mais également l’eau de pluie et la rosée",
  "Épuisement des ressources non renouvelables" => "Correspond à l'épuisement des ressources énergétiques non renouvelables : charbon, gaz, pétrole, uranium.",
  "Eutrophisation (terrestre, eau douce & marine)" => "Correspond à un enrichissement excessif des milieux naturels en nutriments, ce qui conduit à une prolifération et une asphyxie (zone morte)",
  "Utilisation des terres" => "Les terres sont une ressource finie, qui se partage entre milieux naturels (forêt), productifs (agricultures) et urbains. L'usage des terres et les habitats déterminent dans une large mesure la biodiversité. Cette catégorie reflète donc l'impact d'une activité sur la dégradation des terres, en référence à « l'état naturel »",
  "Toxicités (eau douce & humaine)" => "Ecotoxicité d'eau douce, Toxicité humaine cancérigène et non cancérigène. Indicateurs de toxicité via la contamination de l'environnement. Ces indicateurs sont encore peu robustes actuellement",
  "Perte de biodiversité" => "Implique l'extinction d'espèces (végétales ou animales) dans le monde entier, ainsi que la réduction ou la perte locale d'espèces dans un habitat donné",
  "Épuisement des ressources minérales" => "Correspond à l'épuisement des ressources minérales non renouvelables : cuivre, potasse, terres rares, sable"
}

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
  "Pesticide11" => "Huile d'oignon",
  "Pesticide12" => "Bacillus amyloliquefaciens",
  "Pesticide13" => "Bicarbonate"
}

pesticides_effects = {
  "Chlorpyrifos" => "insecticide organophosphoré: perturbations endocriniennes, troubles neurologiques, problèmes respiratoires, irritations cutanées, irritations oculaires, troubles gastro-intestinaux, troubles de la fertilité",
  "Glyphosate" => "herbicide: possibilité de cancérogénicité (en contact direct ou indirect), irritations cutanées, irritations oculaires, problèmes respiratoires, troubles gastro-intestinaux, allergies (en contact direct ou indirect), perturbations endocriniennes",
  "Thiaclopride" => "insecticide néonicotinoïde: irritations cutanées, irritations oculaires, problèmes respiratoires, troubles gastro-intestinaux, troubles neurologiques, troubles de la fertilité",
  "Linuron" => "herbicide : irritations cutanées, irritations oculaires, problèmes respiratoires, troubles gastro-intestinaux, perturbations endocriniennes, troubles de la fertilité",
  "Pendiméthaline" => "herbicide : irritations cutanées, irritations oculaires, problèmes respiratoires, troubles gastro-intestinaux, troubles neurologiques",
  "Difénoconazole" => "fongicide triazole : irritations cutanées, irritations oculaires, problèmes respiratoires, troubles gastro-intestinaux, perturbations endocriniennes, possibles effets sur la fertilité",
  "Azoxystrobine" => "fongicide strobilurine : irritations cutanées, irritations oculaires, problèmes respiratoires, troubles gastro-intestinaux, perturbations endocriniennes, allergies (en contact direct ou indirect)",
  "Pyriméthanil" => "fongicide anilinopyrimidine : irritations cutanées, irritations oculaires, problèmes respiratoires, troubles gastro-intestinaux, allergies, troubles neurologiques",
  "Cuivre en aspersion" => "fongicide et bactéricide: irritations cutanées, irritations oculaires, problèmes respiratoires ",
  "Granulés à l'huile d'oignon" => "répulsif, éliciteur, fongicide: allergies",
  "Bacillus amyloliquefaciens" => "biocontrolant: pas d'effets sur la santé",
  "Bicarbonate" => "fongicide, herbicide, régulateur du pH du sol, répulsif, désinfectant : allergies, irritations cutanées, irritations oculaires, troubles gastro-intestinaux"
}

pesticides_mapping = {
  "Carotte Franprix" => ["Pesticide1", "Pesticide3", "Pesticide4", "Pesticide5", "Pesticide6"],
  "Carotte La Main Verte" => ["Pesticide10", "Pesticide11"],
  "Patate douce Franprix" => ["Pesticide1", "Pesticide2", "Pesticide3"],
  "Patate douce La Main Verte" => [],
  "Kiwi Franprix" => ["Pesticide1", "Pesticide3", "Pesticide7", "Pesticide8", "Pesticide9"],
  "Kiwi La Main Verte" => ["Pesticide10", "Pesticide12", "Pesticide13"]
}

custom_product_1 = Product.new(name: "Carotte")
ProductAlternative.create!(
  product: custom_product_1,
  name: "Carotte Franprix",
  eco_score: worst_product.eco_score,
  environment: worst_product.environment,
  health: worst_product.health.merge(
    pesticides: pesticides_mapping["Carotte Franprix"].map { |p| pesticide_associations[p] },
    pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
  ),
  bar_code: "ABC-abc-1243"
)

ProductAlternative.create!(
  product: custom_product_1,
  name: "Carotte La Main Verte",
  eco_score: best_product.eco_score,
  environment: best_product.environment,
  health: best_product.health.merge(
    pesticides: pesticides_mapping["Carotte La Main Verte"].map { |p| pesticide_associations[p] },
    pesticide_effects: pesticides_mapping["Carotte Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
  ),
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
  health: worst_product.health.merge(
    pesticides: pesticides_mapping["Patate douce Franprix"].map { |p| pesticide_associations[p] },
    pesticide_effects: pesticides_mapping["Patate douce Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
  ),
  bar_code: "123456789"
)

ProductAlternative.create!(
  product: custom_product_2,
  name: "Patate douce La Main Verte",
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
ProductAlternative.create!(
  product: custom_product_3,
  name: "Kiwi Franprix",
  eco_score: worst_product.eco_score,
  environment: worst_product.environment,
  health: worst_product.health.merge(
    pesticides: pesticides_mapping["Kiwi Franprix"].map { |p| pesticide_associations[p] },
    pesticide_effects: pesticides_mapping["Kiwi Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
  ),
  bar_code: "123456789"
)

ProductAlternative.create!(
  product: custom_product_3,
  name: "Kiwi La Main Verte",
  eco_score: best_product.eco_score,
  environment: best_product.environment,
  health: best_product.health.merge(
    pesticides: pesticides_mapping["Kiwi La Main Verte"].map { |p| pesticide_associations[p] },
    pesticide_effects: pesticides_mapping["Kiwi Franprix"].map { |p| pesticides_effects[pesticide_associations[p]] },
  ),
  bar_code: "00000017"
)

puts "Custom products created"
