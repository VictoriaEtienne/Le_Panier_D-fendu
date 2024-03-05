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

CSV_PRODUCTS = File.join('db', 'seeds', 'agribalyse_synthese_v1.csv')

CSV.foreach(CSV_PRODUCTS, headers: true, header_converters: :symbol) do |row|
  product = Product.find_or_create_by(name: row[:nom_du_produit_en_franais])
  ProductAlternative.create!(
    eco_score: row[:score_unique_ef],
    caracteristics: row[:changement_climatique]
  )
  #<CSV::Row code_agb:"26147" code_ciqual:"26147" groupe_daliment:"viandes, œufs, poissons" sousgroupe_daliment:"poissons cuits" nom_du_produit_en_franais:"Vivaneau, cuit" lci_name:"Snapper, cooked" code_saison:"2" code_avion:"0" livraison:"Glacé" matriau_demballage:"PP" prparation:"Four" dqr:"3.56" score_unique_ef:"1.018584" changement_climatique:"5.14661" appauvrissement_de_la_couche_dozone:"9.5738086e-7" rayonnements_ionisants:"1.1184273" formation_photochimique_dozone:"0.079025322" particules_fines:"8.8748946e-7" effets_toxicologiques_sur_la_sant_humaine_substances_noncancrognes:"8.2514113e-8" effets_toxicologiques_sur_la_sant_humaine_substances_cancrognes:"4.5705897e-9" acidification_terrestre_et_eaux_douces:"0.1167088" eutrophisation_eaux_douces:"0.00086705325" eutrophisation_marine:"0.027544536" eutrophisation_terrestre:"0.29874207" cotoxicit_pour_cosystmes_aquatiques_deau_douce:"27.343587" utilisation_du_sol:"18.070403" puisement_des_ressources_eau:"0.63300754" puisement_des_ressources_nergtiques:"86.252396" puisement_des_ressources_minraux:"0.00020339033">
end
