import { Controller } from "@hotwired/stimulus";
import mapboxgl from 'mapbox-gl';
// import MapboxDirections from "@mapbox/mapbox-gl-directions"

export default class extends Controller {
  static values = {
    center: Array,
    zoom: Number,
    markers: Array,
    token: String,
    path: Boolean,
    pathOptions: Object,
    pathCoordinates: Array,
    style: String,
    redMarker: String,
  };

  connect() {
    mapboxgl.accessToken = this.tokenValue;
    let mapOptions = {
      container: this.element, // l'élément container
      style: 'mapbox://styles/mapbox/dark-v11', // style de la carte
      zoom: this.zoomValue, // zoom de la carte
    }
    if (this.centerValue && this.centerValue.length > 0) {
      mapOptions = {
        ...mapOptions,
        center: this.centerValue

      }
    } else {
      mapOptions = {
        ...mapOptions,

      }
    }
    this.map = new mapboxgl.Map(mapOptions);
    if (this.markersValue.length > 0) {
      this._addMarkers();
      this._fitMapToMarkers();
    }

    this.map.on('load', () => {
      if (this.pathValue) {
        this._addPath();
      }
    });
  }

  _addMarkers() {

    let i = 1
    this.markersValue.forEach((marker) => {
      const popup = new mapboxgl.Popup().setHTML(marker.info_window_html);
      const customMarker = document.createElement("div")

      if (this.redMarkerValue && i <= 1) {
        customMarker.innerHTML = this.redMarkerValue
      } else {
        customMarker.innerHTML = this.styleValue
      }

      new mapboxgl.Marker(customMarker).setLngLat(marker).setPopup(popup).addTo(this.map);
      i += 1
    });
  }

  _fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds();

    this.markersValue.forEach((marker) => {
      bounds.extend(marker);
    });

    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15 });
  }

  _addPath() {
    // Vérifiez si les marqueurs sont présents
    if (this.markersValue.length < 2) {
      return; // Besoin d'au moins deux marqueurs pour tracer un chemin
    }

    // Créer un objet GeoJSON pour le chemin
    const pathGeoJSON = {
      type: 'Feature',
      properties: {},
      geometry: {
        type: 'LineString',
        coordinates: this.pathCoordinatesValue || this.markersValue,
      },
    };

    // Ajouter l'objet GeoJSON en tant que source sur la carte
    this.map.addSource('path', {
      type: 'geojson',
      data: pathGeoJSON,
    });

    // Ajouter une couche pour le chemin
    this.map.addLayer({
      id: 'path',
      type: 'line',
      source: 'path',
      layout: {
        'line-join': 'round',
        'line-cap': 'round',
      },
      paint: {
        'line-color': '#1DDD50' || '#000', // Choisissez une couleur pour le chemin 'line-color': '#1DDD50',
        'line-width': this.pathOptionsValue.line_width || 5, // Choisissez une largeur de ligne pour le chemin
      },
    });
  }
}
