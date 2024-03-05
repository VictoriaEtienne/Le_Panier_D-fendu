import { Controller } from "@hotwired/stimulus"
// import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder"

export default class extends Controller {
  static values = { apiKey: String }

  static targets = ["address"]

  connect() {
    this.geocoder = new MapboxGeocoder({
      accessToken: this.apiKeyValue,
      types: "country,region,place,postcode,locality,neighborhood,address"
    })

    // Ajouter les événements "result" et "clear" au geocoder
    this.geocoder.on("result", event => this.setInputValue(event))
    this.geocoder.on("clear", () => this.clearInputValue())

    this.geocoder.addTo(this.element)
  }

  disconnect() {
    this.geocoder.off("result")
    this.geocoder.off("clear")
    this.geocoder.onRemove()
  }

  setInputValue(event) {
    // Mise à jour de la valeur de l'élément cible avec le résultat du géocode
    this.addressTarget.value = event.result["place_name"]
  }

  clearInputValue() {
    // Effacer la valeur de l'élément cible lors de l'événement "clear"
    this.addressTarget.value = ""
  }
}
