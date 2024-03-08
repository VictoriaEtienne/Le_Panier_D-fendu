class ProductAlternativesController < ApplicationController
  def index
    @product_alternatives = ProductAlternative.all
  end

  def show
    @product_alternative = ProductAlternative.find(params[:id])
    @eco_score_element_details = [
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
    @eco_score_element_effect = {
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
  end

  def search
    @product_alternative = ProductAlternative.find_by(bar_code: params[:bar_code])
    # @product_alternative = ProductAlternative.find_by(bar_code: "ABC-abc-1234")
    render json: { redirect_to: product_alternative_path(@product_alternative) }
    # render json: @product_alternative
  end
end
